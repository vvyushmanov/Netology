locals {
  folder_id = "b1gen0ivt5de5o1t09r6"
  cert_id = "fpqepm475a5198kukjht"
}

resource "yandex_kms_symmetric_key" "key-a" {
  name              = "encryption-key"
  description       = "for storage"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" // equal to 1 year
}