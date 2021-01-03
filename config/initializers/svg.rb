# Hack for allowing SVG files. While this hack is here, we should **not**
# allow arbitrary SVG uploads. https://github.com/rails/rails/issues/34665

ActiveStorage::Engine.config
                     .active_storage
                     .content_types_to_serve_as_binary
                     .delete('image/svg+xml')
