
use std log

const time_weight = 0.0002
const file_weight = 2.5

# Rating=(File Weight×File Count)+(Time Weight×Time Since Last Modified)

def sanitize_string [folder: string] {
}


def main [path: string] {
  log info '-----Start-----'
  let folders = ls $path
    | where type == "dir"
    | enumerate
    | insert time_diff {
      |e| (date now) - $e.item.modified }
    | flatten

  # Iterate on each row, and add a column based on other columns.
  let rated_folders = $folders | each {
    $in | insert rating {
      let file_count = ls $in.name | where type == file | length
      let rating = ($file_weight * $file_count) + ($time_weight * ($in.time_diff | $in / 1sec))
      $rating | math floor
    }
  } | sort-by rating --reverse

  $rated_folders | each { |folder|
    let basename = $folder.name | path basename
    # TODO: find some way to detect software version in each folder, and put in name.
    let new_folder_name = $"($folder.rating)-($basename)"
    echo $"($basename) -> ($new_folder_name)"
  }
}
