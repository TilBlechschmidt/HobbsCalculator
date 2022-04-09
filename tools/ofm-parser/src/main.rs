use std::{
    fs::File,
    io::{BufWriter, Write},
    num::ParseFloatError,
};

use roxmltree::{Document, Node};

#[derive(Debug)]
struct Airport<'a> {
    id: &'a str,
    name: &'a str,
    lat: f64,
    lng: f64,
}

impl<'a> Airport<'a> {
    fn to_row(&self) -> String {
        format!(
            "{},{},{},{}",
            self.id,
            self.name.replace("\n", " "),
            self.lat,
            self.lng
        )
    }
}

fn parse_coordinate(coord: &str) -> Result<f64, ParseFloatError> {
    let negative = coord.ends_with("W") || coord.ends_with("S");
    let numeric = coord
        .trim_end_matches(&['W', 'E', 'N', 'S'])
        .parse::<f64>()?;

    if negative {
        Ok(-numeric)
    } else {
        Ok(numeric)
    }
}

fn parse_airport<'a>(airport: Node<'a, 'a>) -> Option<Airport<'a>> {
    let get_field = |tag: &str| {
        airport
            .children()
            .find(|n| n.has_tag_name(tag))
            .as_ref()
            .map(Node::text)
            .flatten()
    };

    let id = get_field("codeIcao").or(get_field("codeGps"))?;
    let name = get_field("txtName")?;
    let airport_type = get_field("codeType")?;

    let lat = parse_coordinate(get_field("geoLat")?).ok()?;
    let lng = parse_coordinate(get_field("geoLong")?).ok()?;

    // Ignore heliports
    if airport_type == "HP" {
        None
    } else {
        Some(Airport { id, name, lat, lng })
    }
}

// To use this tool you have to download and extract the current OpenFlightMaps data for the ED__ region into a folder called `ofmx_ed`
// It is available for download at: https://snapshots.openflightmaps.org/live/2203/ofmx/ed/latest/ofmx_ed.zip
fn main() -> Result<(), Box<dyn std::error::Error>> {
    let ofmx = std::fs::read_to_string("ofmx_ed/embedded/ofmx_ed")?;
    let file = File::create("airports.csv")?;
    let mut output = BufWriter::new(file);

    let doc = Document::parse(&ofmx)?;
    let airports: Vec<roxmltree::Node> = doc
        .descendants()
        .filter(|n| n.has_tag_name("Ahp"))
        .collect();

    let mut skipped = 0;
    for airport in airports {
        if let Some(parsed) = parse_airport(airport) {
            output.write(parsed.to_row().as_bytes())?;
            output.write(b"\n")?;
        } else {
            skipped += 1;
        }
    }

    println!("Skipped {skipped} airports due to missing values");

    Ok(())
}
