class prova {
    
    int funcio (int a, int b) {
        int c = a + b
        /*
        iload_1
        iload_2
        */
        return c;
    }

    public int main (String [] argv) {
        /*        
        aload0
        iconst_2
        iconst_3
        */
        int a = funcio()
        return Integer.parseInt(argv[1])+5;
    }
}
