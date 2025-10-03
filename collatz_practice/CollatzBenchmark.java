import java.util.Scanner;

public class CollatzBenchmark {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);

        long n = Long.parseLong(args[0]);

        if (n < 2) {
            System.err.println("Invalid input");
            System.exit(1);
        }

        long global_max_iterations = 0;
        long max_iterations_begin = 0;
        long global_max = 0;
        long max_begin = 0;
        for (long i = 2; i <= n; ++i) {
            long max = 0;
            long iterations = 0;
            long cur = i;

            System.out.println("\033[2J\033[H----- begin = " + i + " -----");
            System.out.print(cur);
            while (cur != 1) {
                if (cur % 2 == 0) {
                    cur = cur / 2;
                } else {
                    cur = 3 * cur + 1;
                }

                if (cur > max) {
                    max = cur;
                }

                System.out.print(", " + cur);
                iterations++;
            }

            System.out.println();
            System.out.println("Number of iterations spent (begin = " + i + "): " + iterations);
            System.out.println("Largest number encountered (begin = " + i + "): " + max);

            if (max > global_max) {
                global_max = max;
                max_begin = i;
            }

            if (iterations > global_max_iterations) {
                global_max_iterations = iterations;
                max_iterations_begin = i;
            }
        }
        System.out.println("=== Winning Stats for the Collatz Championship ===");
        System.out.println("Highest number reached (begin = " + max_begin + "): " + global_max);
        System.out.println("Most iterations (begin = " + max_iterations_begin + "): " + global_max_iterations);

        sc.close();
    }
}
