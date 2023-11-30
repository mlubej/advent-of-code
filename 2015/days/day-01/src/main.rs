use std::env;
use std::fs;

fn main() {
    let args: Vec<String> = env::args().collect();
    let file_path = &args[1];

    // part 1
    let contents = fs::read_to_string(file_path).expect("Should have been able to read the file");
    let result: usize = contents.matches('(').count() - contents.matches(')').count();
    println!("Result:\n{}", result);

    // part 2
    let mut level = 0;
    for (idx, c) in contents.chars().enumerate() {
        if c == '(' {
            level += 1;
        } else {
            level -= 1;
        }

        if level == -1 {
            println!("{}", idx + 1);
            break;
        }
    }
}
