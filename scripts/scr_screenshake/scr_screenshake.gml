function scr_screenshake(amount)
{
    with (oCameraController)
    {
        shake_amount = max(shake_amount, amount);
    }
}