%% find n seams
function [paths] = find_seams(bg, n)
    [r, c] = size(bg);
    paths = zeros(r, n);
    bg_processed = bg;
    for m = 1:n
        bg_energy = my_sobel(bg_processed);
        [bg_cost, bg_path] = my_cost(bg_energy);
        [cost_min, cost_idx] = min(bg_cost);
        for i = r:-1:1
            bg_processed(i, cost_idx) = 255;
            paths(i, m) = cost_idx;
            cost_idx = bg_path(i, cost_idx) + cost_idx;
        end
    end
end