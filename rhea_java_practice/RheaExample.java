import java.util.Scanner;

public class RheaExample { // the class name must match the file name
	public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
		System.out.println("My name is Rhea"); //This is going to output
		//the name on the current line...and then make a new line. 
		
        int n = 0;
        do {
            System.out.println("Calculate up to the term? ");
            n = scanner.nextInt();

            do {
                if (n < 0){
                    System.out.println("Error– enter a positive number");
                } 
            } while (n < 0);

            if (n == 0) {
                break;
            }
            
            long a = 0; // the data type for this must be "long" because using a data type like integer, is too small to hold the data, since the numbers in the fibonacci sequence grow rapidly. 
            long b = 1; 
            long c = 0;
            long sum = 1; // the sum must start with 1, since the  value of starts incrementing from the third term, therefore it doesnt take into account 1 and 0. 
            long last = 0;
            
            if (n < 20) { 
                System.out.print(a);
                System.out.print("; ");
                System.out.print(b);
                System.out.print("; ");
                for (int number = 2; number <= n; number++) {
                    c = a + b;

                    System.out.print(c);
                    if (number != n) {
                        System.out.print("; ");
                    } else {
                        System.out.println("");
                    }
        
                    sum = sum + c; 
                    a = b; 
                    b = c; 	
                }
                last = c;
                System.out.println(last);
            } else {
                for (int number = 2; number <= n; number++) {
                    c = a + b;
                    sum = sum + c; 
                    a = b; 
                    b = c; 	
                }
                System.out.print("The number is: ");
                System.out.println(c);  
                last = c;
            }

            double average = (double)sum / n; //A floating-point data type (like double) for the average calculation to keep the decimal precision. 
            System.out.println("The average of the numbers is: " + average);// this function will use the sum which has been calculated in one of the conditional statements, "if" or "else", and divide it by the user input "n", to calculate the average. 
                
            // code to count how many digits the term has 
            long temp = last;
            int digit = 0;
            do {
                temp = temp / 10; 
                digit++;
            } while (temp != 0);
            System.out.println("The number of digits is: " + digit);
            System.out.println(" ");	//this is in order to ensure that2 the computer does not show an error
        } while (n != 0);
        // when you use break your execution ends up here
        scanner.close();
    } 
} // it is a good practise to close the scanner, at the end of the <PROGRAM>. 