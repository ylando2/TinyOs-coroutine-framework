interface SetGetI<var_type>
{
  command void set(var_type);
  command  var_type get();
  command message_t *get_message_t();
}

