import java.util.Scanner;

public class Fibonacci {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);

        // print the name
        System.out.println("Eason Qin");

        int n;
        do {
            System.out.print("Calculate up to term (n)? ");
            n = sc.nextInt();

            if (n < 0) {
                System.out.println("Error- enter a positive number.");
            }

        } while (n < 0);

        long a = -1;
        long b = 1;
        long c = 0;
        for (int counter = 0; counter <= n; counter++) {
            c = a + b;

            if (n <= 20) {
                System.out.print(c);
                if (counter < n) {
                    System.out.print("; ");
                }
            }

            a = b;
            b = c;
        }
        if (n > 20) {
            System.out.printf("Term %d is: %d\n", n, c);
        }

        System.out.println("");

        sc.close();
    }
}
