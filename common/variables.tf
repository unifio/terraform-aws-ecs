# Input Variables

## Resource tags
variable "stack_item_fullname" {
  description = "Long form descriptive name for this stack item. This value is used to create the 'application' resource tag for resources created by this stack item."
  type        = "string"
}

variable "stack_item_label" {
  description = "Short form identifier for this stack. This value is used to create the 'Name' resource tag for resources created by this stack item, and also serves as a unique key for re-use."
  type        = "string"
}

## S3 parameters
variable "bucket_prefix" {
  description = "Label to prepend S3 bucket names with."
  type        = "string"
}
