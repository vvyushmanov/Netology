resource "yandex_iam_service_account" "bucket-sa" {
  name = "bucket-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "bucket-sa-editor" {
  folder_id = "b1gen0ivt5de5o1t09r6"
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.bucket-sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "bucket-sa-static-key" {
  service_account_id = yandex_iam_service_account.bucket-sa.id
  description        = "static access key for object storage"
}

resource "yandex_storage_bucket" "bucket-main" {
  access_key = yandex_iam_service_account_static_access_key.bucket-sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.bucket-sa-static-key.secret_key
  bucket     = "iushmanov18091993"

  anonymous_access_flags {
    read = true
    list = false
  }

  default_storage_class = "STANDARD"

  max_size = 5368709120

}

resource "yandex_storage_object" "two-b" {
  access_key = yandex_iam_service_account_static_access_key.bucket-sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.bucket-sa-static-key.secret_key
  bucket     = "${yandex_storage_bucket.bucket-main.id}"

  key = "2b.png"
  source = "assets/2B_Nier_Automata.png"
  acl = "public-read"
}

