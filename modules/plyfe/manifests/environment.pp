class plyfe::environment {
  notify { 'class plyfe::environment declared': }

  include osx::global::expand_print_dialog
  include osx::global::expand_save_dialog

  include plyfe::apps::gems
  include plyfe::apps::mac
  include plyfe::apps::npm

  include projects::all
}