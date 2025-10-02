import java.util.Scanner;

public class Collatz {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);

        // task 1. the name
        System.out.println("Luke Skywalker");

        // task 4. do it in a loop
        int n = 0;
        do {
            // task 2. input number
            System.out.print("What number should we start with (n)? ");
            n = sc.nextInt();

            // task 3. validate until number is >= 2
            if (n < 2) {
                System.out.println("Invalid input, please try again.");
            }
        } while (n < 2);

        // task 10: collatz championship continued: which sequence uses the most
        // iterations?
        int global_max_iterations = 0;
        int max_iterations_begin = 0;
        // task 9: collatz championship: which sequence produces the largest number?
        int global_max = 0;
        int max_begin = 0;
        // task 8: run it from 2 - n
        for (int i = 2; i < n; ++i) {
            // task 7. get the largest number found from the round
            int max = 0;
            // task 6. count the number of times the collatz has been done
            int iterations = 0;
            // task 5. print the collatz numbers, comma separated
            int cur = i; // task <8: this should be n, later it should be i

            System.out.println("----- begin = " + i + " -----"); // task 8: formatting
            System.out.print(cur); // for 5: this is very important!
            while (cur != 1) {
                if (cur % 2 == 0) {
                    cur = cur / 2;
                } else {
                    cur = 3 * cur + 1;
                }

                // largest number
                if (cur > max) {
                    max = cur;
                }

                System.out.print(", " + cur);
                iterations++; // for task 6: obviously for loops may be used
            }
            System.out.println();
            System.out.println("Number of iterations spent (begin = " + i + "): " + iterations);
            System.out.println("Largest number encountered (begin = " + i + "): " + max);

            // ---- task 9 ----
            if (max > global_max) {
                global_max = max;
                max_begin = i;
            }

            // ---- task 10 ----
            if (iterations > global_max_iterations) {
                global_max_iterations = iterations;
                max_iterations_begin = i;
            }
        }
        System.out.println("=== Winning Stats for the Collatz Championship ===");
        // task 9
        System.out.println("Highest number reached (begin = " + max_begin + "): " + global_max);
        // task 10
        System.out.println("Most iterations (begin = " + max_iterations_begin + "): " + global_max_iterations);

        sc.close();
    }
}
