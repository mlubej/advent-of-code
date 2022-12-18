import numpy as np


# https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm#Algorithm
def find_optimal_path_djikstra(array, fill_value=99999):
    current = (0, 0)
    end = tuple(np.array(array.shape) - [1, 1])
    cost_from_zero = np.full_like(array, fill_value=fill_value, dtype=int)
    cost_from_zero[current] = 0
    unvisited = {(x, y) for x in range(array.shape[1]) for y in range(array.shape[0])}

    while True:
        neighbors = set((current[0] + x, current[1] + y) for x, y in [[-1, 0], [1, 0], [0, -1], [0, 1]])
        neighbors &= unvisited

        ccost = cost_from_zero[current]
        for nb in neighbors:
            if ccost + array[nb] < cost_from_zero[nb]:
                cost_from_zero[nb] = ccost + array[nb]

        unvisited -= {current}
        init_cands = {node for node in unvisited if cost_from_zero[node] == fill_value}
        if current == end or len(unvisited) == len(init_cands):
            break

        current = sorted(unvisited - init_cands, key=lambda x: cost_from_zero[x])[0]

    return cost_from_zero[end]


def unify_ranges(ranges):
    ranges = sorted(map(list, ranges))

    new_ranges = [ranges[0]]
    for cs, ce in ranges[1:]:
        ps, pe = new_ranges[-1]
        if cs <= pe:
            new_ranges[-1][1] = max(ce, pe)
        else:
            new_ranges.append([cs, ce])

    return new_ranges
