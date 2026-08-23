function scr_tree_crack_pulse(_tier = 0)
{
    var _k_crack_timer     = [ 6,    8,    11,   4    ];
    var _k_crack_intensity = [ 1.0,  1.35, 1.8,  1.0  ];
    var _k_vignette        = [ 0.15, 0.25, 0.4,  0.2  ];
    var _k_aberration      = [ 0.15, 0.25, 0.4,  0.2  ];
    var _k_bloom           = [ 0.1,  0.18, 0.3,  0.15 ];
    var _k_shake           = [ 4,    7,    11,   3    ];
    var _k_zoom_punch      = [ 0.04, 0.07, 0.11, 0.03 ];
    var _k_snap            = [ 2,    3,    5,    2    ];

    with(oFruit)
    {
        crack_timer = _k_crack_timer[_tier];
        crack_flash = _k_crack_intensity[_tier];
        crack_glow = _k_crack_intensity[_tier];
        cocoon_crack_flash = max(cocoon_crack_flash, _k_crack_intensity[_tier]);
        cocoon_pressure = max(cocoon_pressure, 0.55 + _tier * 0.18);
    }

    with(oTree)
    {
        spawn_snap = max(spawn_snap, _k_snap[_tier]);
    }

    if (instance_exists(oAvoidanceController))
    {
        with(oAvoidanceController)
        {
            vignette_pulse = max(vignette_pulse, _k_vignette[_tier]);
            aberration_pulse = max(aberration_pulse, _k_aberration[_tier]);
            bloom_pulse = max(bloom_pulse, _k_bloom[_tier]);
        }
    }

    if (instance_exists(oCameraController))
    {
        oCameraController.shake = max(oCameraController.shake, _k_shake[_tier]);
        oCameraController.zoom_punch = max(oCameraController.zoom_punch, _k_zoom_punch[_tier]);
    }
}
