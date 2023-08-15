enum RequestMethod {
  get('get'),
  post('post'),
  put('put'),
  patch('patch'),
  delete('delete'),
  head('head'),
  options('options');

  const RequestMethod(this.value);
  final String value;
}
