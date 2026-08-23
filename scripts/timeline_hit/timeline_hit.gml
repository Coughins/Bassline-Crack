function timeline_hit(_frame)
{
    if (last_t < _frame && t >= _frame)
    {
        return true;
    }

    return false;
}

function timeline_hit_many()
{
    for (var i = 0; i < argument_count; i++)
    {
        if (last_t < argument[i] && t >= argument[i])
        {
            return true;
        }
    }

    return false;
}