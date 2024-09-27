import birl

// import birl/duration
import gleam/io

pub fn mounted() {
  let now = birl.now()
  // let two_weeks_later = birl.add(now, duration.weeks(2))
  let birl_iso = birl.to_iso8601(now)

  io.println(birl_iso)
}
