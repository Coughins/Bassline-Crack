varying vec2 v_vTexcoord;


// ================================
// GMS2 UNIFORMS
// ================================

uniform float u_time;
uniform float u_rain_time;  // glyph-cascade clock  (seconds * fall multiplier) — surges on the beat
uniform vec2 u_resolution;

uniform float u_speed;
uniform float u_brightness;

uniform vec3 u_color;
uniform vec3 u_color_deep;
uniform vec3 u_color_hot;

uniform float u_beat;       // 0..1, "we are in a heavy moment"    (~15 frame envelope)
uniform float u_impact;     // 0..1, "a hit just LANDED"           (~8 frame one-shot)
uniform float u_charge;     // 0..1, windup / anticipation         (letterbox-fed, slow)
uniform float u_glitch;     // 0..1, data corruption
uniform float u_roll;       // radians — the corridor twists against the camera's own tilt

uniform vec3 u_shock_r;
uniform vec3 u_shock_p;


// ================================
// CONSTANTS
// ================================

#define ITERATIONS 20


const float STRIP_CHARS_MIN = 7.0;
const float STRIP_CHARS_MAX = 40.0;

const float STRIP_CHAR_HEIGHT = 0.15;
const float STRIP_CHAR_WIDTH  = 0.10;

const float ZCELL_SIZE = 1.0 * (STRIP_CHAR_HEIGHT * STRIP_CHARS_MAX);
const float XYCELL_SIZE = 12.0 * STRIP_CHAR_WIDTH;


const int BLOCK_SIZE = 10;
const int BLOCK_GAP = 2;


const float WALK_SPEED = 1.0 * XYCELL_SIZE;
const float BLOCKS_BEFORE_TURN = 3.0;


const float PI = 3.14159265359;



// --- grade: white-hot head -> energy body -> blood tail ---
const float HEAD_FALLOFF    = 0.55;
const float TAIL_BLOOD      = 1.00;
const float DEPTH_BLEED     = 0.030;
const float DEPTH_BLEED_MAX = 0.75;

// --- wound drip: the leading glyph drags a smear of light below itself ---
const float BLEED_CHARS_MIN = 0.9;
const float BLEED_CHARS_MAX = 3.5;    // ...at full charge
const float BLEED_ALPHA     = 0.55;

// --- beat response ---
const float BEAT_GAIN   = 0.85;       // extra rune brightness at full beat
const float IMPACT_GAIN = 1.25;
const float GLOW_BEAT   = 0.22;
const float GLOW_IMPACT = 0.34;

// --- cinematic camera (the forward axis is 2.0; smaller = wider lens) ---
const float BEAT_FOV   = 0.22;        // lens widens on the beat
const float IMPACT_FOV = 0.38;
const float DOLLY      = 0.42;

// --- charge / windup ---
const float CHARGE_PINCH   = 0.055;
const float CHARGE_DENSITY = 18.0;

// --- shockwave shells ---
const float SHOCK_W    = 2.6;
const float SHOCK_FILL = 1.6;

// --- data corruption bands ---
const float GLITCH_BANDS = 13.0;
const float GLITCH_SLIP  = 2.2;

// --- anime impact frame ---
const float SPEED_LINES     = 30.0;
const float SPEED_LINE_GAIN = 0.90;
const float IMPACT_FLASH    = 0.35;

// --- ambient corridor fog (see the note at the bottom of rain()) ---
const float AMBIENT_BASE   = 0.035;
const float AMBIENT_CHARGE = 0.050;
const float AMBIENT_BEAT   = 0.080;


// ================================
// RANDOM / HASH FUNCTIONS
// ================================

float hash(float v)
{
    return fract(sin(v) * 43758.5453123);
}


float hash(vec2 v)
{
    return hash(dot(v, vec2(5.3983, 5.4427)));
}


vec2 hash2(vec2 v)
{
    v = v * mat2(
        127.1, 311.7,
        269.5, 183.3
    );

    return fract(sin(v) * 43758.5453123);
}


vec4 hash4(vec2 v)
{
    return fract(
        sin(vec4(
            dot(v, vec2(127.1,311.7)),
            dot(v, vec2(269.5,183.3)),
            dot(v, vec2(113.5,271.9)),
            dot(v, vec2(246.1,124.6))
        ))
        *
        43758.5453123
    );
}


vec4 hash4(vec3 v)
{
    return fract(
        sin(vec4(
            dot(v, vec3(127.1,311.7,74.7)),
            dot(v, vec3(269.5,183.3,246.1)),
            dot(v, vec3(113.5,271.9,124.6)),
            dot(v, vec3(271.9,269.5,311.7))
        ))
        *
        43758.5453123
    );
}


// ================================
// SHOCKWAVE SHELLS
// ================================

float shock_at(float d)
{
    vec3 dist = abs(vec3(d) - u_shock_r);

    vec3 band = smoothstep(SHOCK_W, 0.0, dist) * u_shock_p;

    return clamp(band.x + band.y + band.z, 0.0, 1.0);
}


// ================================
// SYMBOL / RUNE FUNCTIONS
// ================================

float rune_line(vec2 p, vec2 a, vec2 b)
{
    p -= a;
    b -= a;

    float h = clamp(
        dot(p,b) / dot(b,b),
        0.0,
        1.0
    );

    return length(p - b*h);
}


float rune(vec2 U, vec2 seed, float highlight)
{
    float d = 1e5;


    for(int i = 0; i < 4; i++)
    {
        vec4 pos = hash4(seed);

        seed += 1.0;


        if(i == 0)
            pos.y = 0.0;

        if(i == 1)
            pos.x = 0.999;

        if(i == 2)
            pos.x = 0.0;

        if(i == 3)
            pos.y = 0.999;


        vec4 snaps = vec4(2.0,3.0,2.0,3.0);

        pos = (floor(pos * snaps)+0.5)/snaps;


        if(pos.xy != pos.zw)
        {
            d = min(
                d,
                rune_line(U,pos.xy,pos.zw+0.001)
            );
        }
    }


    return smoothstep(0.1,0.0,d)
        +
        highlight * smoothstep(0.4,0.0,d);
}



float random_char(vec2 outer, vec2 inner, float highlight)
{
    vec2 seed = vec2(
        dot(outer,vec2(269.5,183.3)),
        dot(outer,vec2(113.5,271.9))
    );


    return rune(
        inner,
        seed,
        highlight
    );
}
// ================================
// DIGITAL RAIN RAYCAST
// ================================

vec3 rain(vec3 ro3, vec3 rd3, float time)
{
    vec4 result = vec4(0.0);


    vec2 ro2 = vec2(ro3.xy);
    vec2 rd2 = normalize(vec2(rd3.x, rd3.y));


    bool prefer_dx = abs(rd2.x) > abs(rd2.y);


    float t3_to_t2 =
        prefer_dx
        ? rd3.x / rd2.x
        : rd3.y / rd2.y;



    ivec3 cell_side = ivec3(
        step(0.0, rd3)
    );


    ivec3 cell_shift = ivec3(
        sign(rd3)
    );



    float t2 = 0.0;


    ivec2 next_cell =
        ivec2(
            floor(ro2 / XYCELL_SIZE)
        );



    float chars_min =
        mix(STRIP_CHARS_MIN, CHARGE_DENSITY, u_charge);


    float glow_gain =
        0.2
        +
        u_beat * GLOW_BEAT
        +
        u_impact * GLOW_IMPACT;


    float rune_gain =
        1.0
        +
        u_beat * BEAT_GAIN
        +
        u_impact * IMPACT_GAIN;



    for(int i = 0; i < ITERATIONS; i++)
    {

        ivec2 cell = next_cell;


        float t2s = t2;



        vec2 side =
            vec2(next_cell + cell_side.xy)
            *
            XYCELL_SIZE;



        vec2 t2_side =
            (side-ro2)
            /
            rd2;



        if(t2_side.x < t2_side.y)
        {
            t2 = t2_side.x;
            next_cell.x += cell_shift.x;
        }
        else
        {
            t2 = t2_side.y;
            next_cell.y += cell_shift.y;
        }




        // ================================
        // BLOCK GAPS
        // ================================


        vec2 cell_in_block =
            fract(
                vec2(cell)
                /
                float(BLOCK_SIZE)
            );


        float gap =
            float(BLOCK_GAP)
            /
            float(BLOCK_SIZE);



        if(
            cell_in_block.x < gap ||
            cell_in_block.y < gap ||
            (
                cell_in_block.x < gap + 0.1 &&
                cell_in_block.y < gap + 0.1
            )
        )
        {
            continue;
        }




        float t3s =
            t2s / t3_to_t2;



        float pos_z =
            ro3.z + rd3.z * t3s;



        float xycell_hash =
            hash(vec2(cell));



        float z_shift =
            xycell_hash * 11.0
            -
            time *
            (
                0.5
                +
                xycell_hash
                +
                xycell_hash * xycell_hash
                +
                pow(xycell_hash,16.0)*3.0
            );



        float char_z_shift =
            floor(
                z_shift / STRIP_CHAR_HEIGHT
            );


        z_shift =
            char_z_shift *
            STRIP_CHAR_HEIGHT;



        int zcell =
            int(
                floor(
                    (pos_z-z_shift)
                    /
                    ZCELL_SIZE
                )
            );



        for(int j = 0; j < 2; j++)
        {

            vec4 cell_hash =
                hash4(
                    vec3(
                        float(cell.x),
                        float(cell.y),
                        float(zcell)
                    )
                );



            vec4 cell_hash2 =
                fract(
                    cell_hash *
                    vec4(
                        127.1,
                        311.7,
                        271.9,
                        124.6
                    )
                );



            float chars_count =
                cell_hash.w *
                (
                    STRIP_CHARS_MAX -
                    chars_min
                )
                +
                chars_min;



            float target_length =
                chars_count *
                STRIP_CHAR_HEIGHT;



            float target_rad =
                STRIP_CHAR_WIDTH / 2.0;



            float target_z =
                (
                    float(zcell)
                    *
                    ZCELL_SIZE
                    +
                    z_shift
                )
                +
                cell_hash.z *
                (
                    ZCELL_SIZE -
                    target_length
                );



            vec2 target =
                vec2(cell)
                *
                XYCELL_SIZE
                +
                target_rad
                +
                cell_hash.xy *
                (
                    XYCELL_SIZE -
                    target_rad*2.0
                );



            vec2 s =
                target-ro2;



            float tmin =
                dot(s,rd2);



            if(
                tmin >= t2s &&
                tmin <= t2
            )
            {

                float u =
                    s.x * rd2.y -
                    s.y * rd2.x;



                if(abs(u)<target_rad)
                {

                    u =
                        (u/target_rad+1.0)
                        /
                        2.0;



                    float z =
                        ro3.z +
                        rd3.z *
                        tmin /
                        t3_to_t2;



                    float v =
                        (z-target_z)
                        /
                        target_length;



                    float bleed_span =
                        mix(
                            BLEED_CHARS_MIN,
                            BLEED_CHARS_MAX,
                            u_charge
                        )
                        /
                        max(chars_count, 1.0);



                    if(v > -bleed_span && v < 1.0)
                    {

                        float depth =
                            tmin / t3_to_t2;


                        float a = 0.0;

                        vec3 col = vec3(0.0);



                        if(v >= 0.0)
                        {
                            // ---- GLYPH ----

                            float c =
                                floor(
                                    v *
                                    chars_count
                                );


                            float q =
                                fract(
                                    v *
                                    chars_count
                                );



                            vec2 char_hash =
                                hash2(
                                    vec2(
                                        c + char_z_shift,
                                        cell_hash2.x
                                    )
                                );



                            if(
                                char_hash.x >= 0.1 ||
                                c == 0.0
                            )
                            {

                                float time_factor =
                                    floor(
                                        c == 0.0
                                        ?
                                        time*5.0
                                        :
                                        time *
                                        (
                                            cell_hash2.z
                                            +
                                            cell_hash2.w *
                                            cell_hash2.w *
                                            4.0 *
                                            pow(char_hash.y,4.0)
                                        )
                                    );



                                a =
                                    random_char(
                                        vec2(
                                            char_hash.x,
                                            time_factor
                                        ),
                                        vec2(u,q),
                                        max(
                                            1.0,
                                            3.0-c/2.0
                                        )*glow_gain
                                    );



                                a *= clamp(
                                    (
                                        chars_count
                                        -
                                        0.5
                                        -
                                        c
                                    )
                                    /
                                    2.0,
                                    0.0,
                                    1.0
                                );


                                a *= rune_gain;



                                // ---- GRADE ----

                                float head =
                                    exp(-c * HEAD_FALLOFF);


                                float tail =
                                    c / max(chars_count, 1.0);


                                col = mix(
                                    u_color,
                                    u_color_deep,
                                    tail * tail * TAIL_BLOOD
                                );


                                col = mix(
                                    col,
                                    u_color_hot,
                                    head * head * (0.5 + 0.5*u_beat)
                                );
                            }
                        }

                        else
                        {
                            // ---- WOUND DRIP ----

                            float dv =
                                -v / bleed_span;


                            float w =
                                1.0 - abs(u*2.0 - 1.0);


                            a =
                                (1.0-dv) * (1.0-dv)
                                *
                                BLEED_ALPHA
                                *
                                pow(max(w, 0.0), 1.5 + dv*4.0)
                                *
                                rune_gain;


                            col = mix(
                                u_color_hot,
                                u_color_deep,
                                dv
                            );
                        }



                        // ---- DEPTH + SHOCKWAVE ----

                        col = mix(
                            col,
                            u_color_deep,
                            clamp(depth * DEPTH_BLEED, 0.0, DEPTH_BLEED_MAX)
                        );


                        float sh = shock_at(depth);

                        col = mix(col, u_color_hot, sh);

                        a *= 1.0 + sh * SHOCK_FILL;



                        a = clamp(a, 0.0, 1.0);



                        if(a>0.0)
                        {

                            float attenuation =
                                1.0 +
                                pow(
                                    0.06 * depth,
                                    2.0
                                );



                            col /= attenuation;



                            col *= u_brightness;



                            float old_alpha =
                                result.a;



                            result.a =
                                old_alpha +
                                (
                                    1.0-old_alpha
                                )
                                *
                                a;



                            result.xyz =
                                (
                                    result.xyz *
                                    old_alpha
                                    +
                                    col *
                                    (
                                        1.0-old_alpha
                                    )
                                    *
                                    a
                                )
                                /
                                result.a;



                            if(result.a > 0.98)
                                return result.xyz;
                        }
                    }
                }
            }


            zcell += cell_shift.z;
        }
    }


    vec3 ambient =
        mix(u_color_deep, u_color, 0.3)
        *
        (
            AMBIENT_BASE
            +
            u_charge * AMBIENT_CHARGE
            +
            u_beat * AMBIENT_BEAT
        )
        *
        u_brightness;

    return result.xyz * result.a + ambient * (1.0 - result.a);
}
// ================================
// CAMERA HELPERS
// ================================

vec2 rotate(vec2 v, float a)
{
    float s = sin(a);
    float c = cos(a);

    mat2 m = mat2(
        c,-s,
        s,c
    );

    return m*v;
}



vec3 rotateX(vec3 v,float a)
{
    float s = sin(a);
    float c = cos(a);

    return mat3(
        1.0,0.0,0.0,
        0.0,c,-s,
        0.0,s,c
    ) * v;
}



vec3 rotateY(vec3 v,float a)
{
    float s = sin(a);
    float c = cos(a);

    return mat3(
        c,0.0,-s,
        0.0,1.0,0.0,
        s,0.0,c
    ) * v;
}



vec3 rotateZ(vec3 v,float a)
{
    float s = sin(a);
    float c = cos(a);

    return mat3(
        c,-s,0.0,
        s,c,0.0,
        0.0,0.0,1.0
    ) * v;
}



float smoothstep1(float x)
{
    return smoothstep(
        0.0,
        1.0,
        x
    );
}



// ================================
// MAIN
// ================================

void main()
{
    vec2 fragCoord =
        v_vTexcoord *
        u_resolution;



    vec2 uv =
        (
            fragCoord * 2.0 -
            u_resolution
        )
        /
        u_resolution.y;


    vec2 uv0 = uv;



    float time =
        u_time *
        u_speed;


    float rain_time =
        u_rain_time *
        u_speed;



    // ============================================================
    // CINEMATIC FRAMING
    // ============================================================

    uv = rotate(uv, u_roll);


    uv *= 1.0 - u_charge * CHARGE_PINCH * dot(uv, uv);


    float punch =
        u_beat * BEAT_FOV
        +
        u_impact * IMPACT_FOV;


    vec3 rd =
        vec3(
            uv.x,
            2.0 - punch,
            uv.y
        );



    float turn_rad =
        0.25 /
        BLOCKS_BEFORE_TURN;



    float turn_abs_time =
        (PI/2.0 * turn_rad)
        *
        1.5;



    float turn_time =
        turn_abs_time /
        (
            1.0 -
            2.0*turn_rad +
            turn_abs_time
        );



    float level1_size =
        float(BLOCK_SIZE)
        *
        BLOCKS_BEFORE_TURN
        *
        XYCELL_SIZE;



    float level2_size =
        4.0 *
        level1_size;



    float gap_size =
        float(BLOCK_GAP)
        *
        XYCELL_SIZE;



    vec3 ro =
        vec3(
            gap_size/2.0,
            gap_size/2.0,
            0.0
        );



    float tq =
        fract(
            time /
            (level2_size*4.0)
            *
            WALK_SPEED
        );



    float t8 =
        fract(tq*4.0);



    float t1 =
        fract(t8*8.0);



    vec2 prev;

    vec2 dir;



    if(tq < 0.25)
    {
        prev = vec2(0.0);
        dir = vec2(0.0,1.0);
    }
    else if(tq < 0.5)
    {
        prev = vec2(0.0,1.0);
        dir = vec2(1.0,0.0);
    }
    else if(tq < 0.75)
    {
        prev = vec2(1.0,1.0);
        dir = vec2(0.0,-1.0);
    }
    else
    {
        prev = vec2(1.0,0.0);
        dir = vec2(-1.0,0.0);
    }



    float angle =
        floor(tq*4.0);



    prev *= 4.0;



    const float first_turn_look_angle = 0.4;
    const float second_turn_drift_angle = 0.5;
    const float fifth_turn_drift_angle = 0.25;



    vec2 turn;

    float turn_sign = 0.0;

    vec2 dirL =
        rotate(dir,-PI/2.0);

    vec2 dirR =
        -dirL;


    float up_down = 0.0;

    float rotate_on_turns = 1.0;

    float roll_on_turns = 1.0;

    float add_angle = 0.0;



    if(t8 < 0.125)
    {
        turn = dirL;
        turn_sign=-1.0;

        angle -=
            first_turn_look_angle *
            (
                max(
                    0.0,
                    t1-(1.0-turn_time*2.0)
                )
                /
                turn_time
                -
                max(
                    0.0,
                    t1-(1.0-turn_time)
                )
                /
                turn_time
                *
                2.5
            );

        roll_on_turns=0.0;
    }

    else if(t8 < 0.25)
    {
        prev += dir;

        turn=dir;

        dir=dirL;

        angle-=1.0;

        turn_sign=1.0;

        add_angle +=
            first_turn_look_angle*0.5
            +
            (
                -first_turn_look_angle*0.5
                +
                1.0
                +
                second_turn_drift_angle
            )
            *
            t1;


        rotate_on_turns=0.0;
        roll_on_turns=0.0;
    }

    else if(t8 < 0.375)
    {
        prev += dir+dirL;

        turn=dirR;

        turn_sign=1.0;

        add_angle +=
            second_turn_drift_angle *
            sqrt(1.0-t1);
    }

    else if(t8 < 0.5)
    {
        prev += dir+dir+dirL;

        turn=dirR;

        dir=dirR;

        angle+=1.0;

        turn_sign=0.0;

        up_down =
            sin(t1*PI)
            *
            0.37;
    }

    else if(t8 < 0.625)
    {
        prev += dir+dir;

        turn=dir;

        dir=dirR;

        angle+=1.0;

        turn_sign=-1.0;

        up_down =
            sin(
                -min(
                    1.0,
                    t1/(1.0-turn_time)
                )
                *
                PI
            )
            *
            0.37;
    }

    else if(t8 < 0.75)
    {
        prev += dir+dir+dirR;

        turn=dirL;

        turn_sign=-1.0;

        add_angle -=
            (
                fifth_turn_drift_angle+1.0
            )
            *
            smoothstep1(t1);

        rotate_on_turns=0.0;
        roll_on_turns=0.0;
    }

    else if(t8 < 0.875)
    {
        prev += dir+dir+dir+dirR;

        turn=dir;

        dir=dirL;

        angle-=1.0;

        turn_sign=1.0;

        add_angle -=
            fifth_turn_drift_angle
            -
            smoothstep1(t1)
            *
            (
                fifth_turn_drift_angle*2.0
                +
                1.0
            );


        rotate_on_turns=0.0;
        roll_on_turns=0.0;
    }

    else
    {
        prev += dir+dir+dir;

        turn=dirR;

        turn_sign=1.0;

        angle +=
            fifth_turn_drift_angle *
            (
                1.5 *
                min(
                    1.0,
                    (1.0-t1)/turn_time
                )
                -
                0.5 *
                smoothstep1(
                    1.0 -
                    min(
                        1.0,
                        t1/(1.0-turn_time)
                    )
                )
            );
    }



    angle += add_angle;



    rd =
        rotateX(
            rd,
            up_down
        );



    vec2 p;



    if(turn_sign == 0.0)
    {
        p =
            prev +
            dir *
            (
                turn_rad +
                t1
            );
    }

    else if(t1 > (1.0-turn_time))
    {

        float tr =
            (
                t1 -
                (1.0-turn_time)
            )
            /
            turn_time;



        vec2 c =
            prev +
            dir*(1.0-turn_rad)
            +
            turn*turn_rad;



        p =
            c +
            turn_rad *
            rotate(
                dir,
                (tr-1.0)
                *
                turn_sign
                *
                PI/2.0
            );



        angle +=
            tr *
            turn_sign *
            rotate_on_turns;



        rd =
            rotateY(
                rd,
                sin(
                    tr*
                    turn_sign*
                    PI
                )
                *
                0.2
                *
                roll_on_turns
            );
    }

    else
    {

        t1 /=
            (1.0-turn_time);


        p =
            prev +
            dir *
            (
                turn_rad +
                (
                    1.0 -
                    turn_rad*2.0
                )
                *
                t1
            );
    }



    rd =
        rotateZ(
            rd,
            angle*PI/2.0
        );



    ro.xy +=
        level1_size *
        p;



    ro +=
        rd * (0.2 + punch * DOLLY);



    // ============================================================
    // DATA CORRUPTION BANDS
    // ============================================================

    if(u_glitch > 0.001)
    {
        float band =
            floor(uv0.y * GLITCH_BANDS);


        float seed =
            hash(band * 1.7 + floor(rain_time * 9.0));


        float on =
            step(1.0 - u_glitch * 0.55, seed);


        ro.z +=
            (hash(seed * 37.0) - 0.5)
            *
            u_glitch
            *
            GLITCH_SLIP
            *
            on;
    }



    rd =
        normalize(rd);



    vec3 col =
        rain(
            ro,
            rd,
            rain_time
        );



    // ============================================================
    // IMPACT FRAME
    // ============================================================

    if(u_impact > 0.001)
    {
        float ang =
            atan(uv0.y, uv0.x);


        float line_id =
            floor(ang / (2.0*PI) * SPEED_LINES);


        float lit =
            step(
                0.72,
                hash(line_id * 3.7 + floor(rain_time * 12.0))
            );


        float reach =
            smoothstep(0.30, 1.35, length(uv0));


        col +=
            u_color_hot
            *
            lit
            *
            reach * reach
            *
            u_impact
            *
            SPEED_LINE_GAIN
            *
            u_brightness;


        col +=
            u_color_hot
            *
            u_impact * u_impact
            *
            IMPACT_FLASH
            *
            u_brightness;
    }



    gl_FragColor =
        vec4(
            col,
            1.0
        );
}
