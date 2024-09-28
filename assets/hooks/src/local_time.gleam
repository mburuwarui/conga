// import birl
// import gleam/result

pub fn mounted() {
  convert_time()
}

pub fn updated() {
  convert_time()
}

fn convert_time() {
  // let element = get_element()

  // use utc_date <- result.try(get_attribute(element, "date-utc"))
  // let assert Ok(parsed_date) = birl.parse(utc_date)
  //
  // let eat_date = birl.set_timezone(parsed_date, "Africa/Nairobi")
  // use formatted_date <- result.try(birl.to_http(eat_date))

  // set_text_content(element, "2016-05-24T13:26:08.003Z")

  get_element()
}

@external(javascript, "./dom.js", "getElement")
fn get_element() -> Element

// @external(javascript, "./dom.mjs", "getAttribute")
// fn get_attribute(element: Element, name: String) -> Result(String, Nil)

// @external(javascript, "./dom.mjs", "setTextContent")
// fn set_text_content(element: Element, content: String) -> Nil

pub type Element
