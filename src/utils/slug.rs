use rand::{rng, Rng};

const CHARSET: &[u8] = b"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

pub fn generate_slug(length: usize) -> String {
    let mut rng = rng();
    let mut slug = String::with_capacity(length);

    for _ in 0..length {
        let random_index = rng.random_range(0..CHARSET.len());
        let random_char = CHARSET[random_index] as char;
        slug.push(random_char);
    }

    slug
}
