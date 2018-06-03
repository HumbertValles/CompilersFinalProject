// test local variables
main()
{ int n; 
  n = $0;
  if (n > 2 || n < 10){
  	n = n++;
  }
  return n;
}
