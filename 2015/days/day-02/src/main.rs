use std::fs;

fn main() {
    let contents = fs::read_to_string("input.txt").expect("Something went wrong reading the file");

    // part 1
    let mut area = 0;
    let mut ribbon = 0;

    for line in contents.lines() {
        let mut vec: Vec<u32> = line
            .split("x")
            .map(|x| x.trim().parse::<u32>().unwrap())
            .collect();
        vec.sort();
        let (a, b, c) = (vec[0], vec[1], vec[2]);
        area += 2 * (a * b + b * c + c * a) + a * b;
        ribbon += 2 * a + 2 * b + a * b * c;
    }
    println!("{area} and {ribbon}");
}
