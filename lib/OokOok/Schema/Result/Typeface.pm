use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::Typeface

# ABSTRACT: a typeface resource collection

editioned_table OokOok::Schema::Result::Typeface {

  has_editions;

  owns_many typeface_fonts => 'OokOok::Schema::Result::TypefaceFont';

}
