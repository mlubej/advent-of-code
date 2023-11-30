use md5;

fn main() {
    let base = &"yzbqklnj";

    let (x, res) = find_md5(base, 5);
    println!("5 zeros: {}, ({})", x, res);

    let (x, res) = find_md5(base, 5);
    println!("6 zeros: {}, ({})", x, res);
}

fn find_md5(base: &str, num_zeros: usize) -> (u64, String) {
    let mut x: u64 = 0;
    let mut result: String;

    loop {
        let mut hex = base.to_owned();
        hex.push_str(&x.to_string());

        let digest = md5::compute(hex);
        result = format!("{:x}", digest);
        if result.starts_with(&"0".repeat(num_zeros)) {
            break;
        }
        x += 1;
    }
    (x, result)
}
