pts = [];

with (oWave)
{
    array_push(other.pts,
    {
        x : x,
        y : y
    });
}

array_sort(pts, function(a,b)
{
    return a.y - b.y;
});