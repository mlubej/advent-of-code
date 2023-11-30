use std::collections::HashSet;
use std::fs;

fn main() {
    let contents = fs::read_to_string("input.txt").expect("Something went wrong reading the file");

    let [mut x1, mut y1] = [0; 2];
    let mut houses_pt1: HashSet<[i32; 2]> = HashSet::new();
    houses_pt1.insert([x1, y1]);

    let [mut x21, mut x22, mut y21, mut y22] = [0; 4];
    let mut houses_pt2: HashSet<[i32; 2]> = HashSet::new();
    houses_pt2.insert([x21, y21]);

    for (cdx, c) in contents.chars().enumerate() {
        match c {
            '>' => {
                x1 += 1;
                if cdx % 2 == 0 {
                    x21 += 1
                } else {
                    x22 += 1
                }
            }
            '<' => {
                x1 -= 1;
                if cdx % 2 == 0 {
                    x21 -= 1
                } else {
                    x22 -= 1
                }
            }

            '^' => {
                y1 += 1;
                if cdx % 2 == 0 {
                    y21 += 1
                } else {
                    y22 += 1
                }
            }
            'v' => {
                y1 -= 1;
                if cdx % 2 == 0 {
                    y21 -= 1
                } else {
                    y22 -= 1
                }
            }

            _ => continue,
        }

        houses_pt1.insert([x1, y1]);

        if cdx % 2 == 0 {
            houses_pt2.insert([x21, y21]);
        } else {
            houses_pt2.insert([x22, y22]);
        }
    }
    println!("{}", houses_pt1.len());
    println!("{}", houses_pt2.len());
}
