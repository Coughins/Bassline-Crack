            var _k_destroy_margin_x = room_width * 2;
            var _k_destroy_margin_y = room_height * 2;
            if (
                x < -_k_destroy_margin_x || x > room_width + _k_destroy_margin_x ||
                y < -_k_destroy_margin_y || y > room_height + _k_destroy_margin_y
            ) {
                instance_destroy();
            }