import re


def explode(x):
    depth = 0
    for idx, c in enumerate(x):
        if c == "[":
            depth += 1
        elif c == "]":
            depth -= 1
        else:
            pass

        if depth == 5:
            pair = re.search(r"(\[\d+,\d+\])", x[idx:]).group(1)
            left, right = x[idx:].split(pair, 1)
            left = x[:idx] + left

            lg = re.search(f"(.*[^\d]+)(\d+)([^\d]*)", left)
            rg = re.search(f"([^\d]*)(\d+)([^\d]+.*)", right)

            nleft = left
            nright = right

            if lg is not None:
                nleft = f"{lg.group(1)}{int(lg.group(2)) + eval(pair)[0]}{lg.group(3)}"

            if rg is not None:
                nright = f"{rg.group(1)}{int(rg.group(2)) + eval(pair)[1]}{rg.group(3)}"

            new_x = nleft + "0" + nright
            return new_x, True

    return x, False


def split(x):
    g = re.search(r"(\d{2,})", x)

    if g is not None:
        num = int(g.group(1))
        nleft, nright = x.split(g.group(1), 1)
        new_x = nleft + f"[{num//2},{(num+1)//2}]" + nright
        return new_x, True

    return x, False


def reduce_number(x):
    while True:
        x, exploded = explode(x)
        if not exploded:
            x, splitted = split(x)
            if not splitted:
                break

    return x


def reduce_pair(x, y):
    return reduce_number(f"[{x},{y}]")


def reduce_list(array):
    total = array[0]
    for number in array[1:]:
        total = reduce_pair(total, number)

    return total


def magnitude(pair):
    if isinstance(pair, int):
        return pair
    else:
        left = magnitude(pair[0])
        right = magnitude(pair[1])
        return 3 * left + 2 * right
