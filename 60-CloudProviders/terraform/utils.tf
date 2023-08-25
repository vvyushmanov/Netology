# resource "local_file" "name" {
#   filename = "test.sh"
#   content = "${templatefile(
#         "http-server-bootstrap.sh.tftpl", 
#         { 
#           bucket = "${yandex_storage_object.two-b.bucket}", 
#           file = "${yandex_storage_object.two-b.key}" 
#         }
#       )
#     }"
# }