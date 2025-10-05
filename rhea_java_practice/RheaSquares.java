import java.util.Scanner;

public class RheaSquares {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
		System.out.println("My name is Rhea"); //This is going to output
		//the name on the current line...and then make a new line. 
		
        int n;
        long temp;
        long remainder;
            System.out.println("Please enter a number less than 10: ");
            n = scanner.nextInt();

            do {
                  System.out.print(">>> Error please enter again: ");
                  n = scanner.nextInt();
            } while (n > 9 || n < 1);
            // calculating the width of the maximum number
            int max = (int)Math.pow(n, n);
            int maxLen = 0;
            int temp = max;
            do {
                temp = temp / 10;
                maxLen++;
            } while (temp != 0);
            maxLen = (maxLen-1) / 3;

            for (int number = 1; number < n+1; number++){
                int square = number * number;
			    int power = (int) Math.pow(n, number);
                System.out.print(number);
                if (square < 10) {
					System.out.print("  " + square);
	   		    } else {
                    System.out.print(" " + square);
                    System.out.print("	");
                    
                    //code for printing it right to left 
                    String buff = ""; 

                    int numDigits = 0;
                    temp = power;
                    in
                    do {
                        temp = temp / 10; 
                        numDigits++;
                    } while (temp != 0);



                    System.out.print(power);
				}
			}
                                      
	    scanner.close();
    }
}
