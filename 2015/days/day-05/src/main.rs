// use std::collections::HashSet;
use regex::Regex;
use std::fs;

const VOWELS: [char; 5] = ['a', 'e', 'i', 'o', 'u'];
const FORBIDDEN: [&str; 4] = ["ab", "cd", "pq", "xy"];

fn main() {
    let contents = fs::read_to_string("input.txt").expect("Something went wrong reading the file");

    let mut num_nice = 0;
    for line in contents.lines() {
        if is_nice(line) {
            num_nice += 1;
        }
    }

    println!("{num_nice}")
}

fn is_nice(line: &str) -> bool {
    // count vowels
    let mut vowels_count = 0;
    for ch in VOWELS {
        vowels_count += line.matches(ch).count();
    }

    // count duplicates
    let mut has_duplicates: bool = false;
    let ch_vec: Vec<char> = line.chars().collect();
    for i in 0..line.len() - 1 {
        if ch_vec[i] == ch_vec[i + 1] {
            has_duplicates = true;
            break;
        }
    }

    // check forbidden strings
    let mut is_forbidden: bool = false;
    for sub in FORBIDDEN {
        if line.matches(sub).count() > 0 {
            is_forbidden = true;
            break;
        }
    }

    if vowels_count >= 3 && has_duplicates && !is_forbidden {
        true
    } else {
        false
    }
}

fn is_nice_pt2(line: &str) -> bool {
    // count recurring groups
    let ch_vec: Vec<char> = line.chars().collect();
    for i in 0..line.len() - 1 {
        let sub = &line[i..i + 1];
        let re = Regex::new(sub).unwrap();
    }

    //

    // let mut vowels_count = 0;
    // for ch in VOWELS {
    //     vowels_count += line.matches(ch).count();
    // }

    // // count duplicates
    // let mut has_duplicates: bool = false;
    // let ch_vec: Vec<char> = line.chars().collect();
    // for i in 0..line.len() - 1 {
    //     if ch_vec[i] == ch_vec[i + 1] {
    //         has_duplicates = true;
    //         break;
    //     }
    // }

    // // check forbidden strings
    // let mut is_forbidden: bool = false;
    // for sub in FORBIDDEN {
    //     if line.matches(sub).count() > 0 {
    //         is_forbidden = true;
    //         break;
    //     }
    // }

    if vowels_count >= 3 && has_duplicates && !is_forbidden {
        true
    } else {
        false
    }
}
