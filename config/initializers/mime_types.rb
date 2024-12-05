# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
Mime::Type.register "application/vnd.openxmlformats-officedocument.wordprocessingml.document", :docx
Mime::Type.register "application/msword", :doc
Mime::Type.register "application/pdf", :pdf
Mime::Type.register "application/xls", :xls
