import java.util.Scanner;

public class StatisticsPracticeTest {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);

        System.out.print("How many numbers to process? ");
        int num = sc.nextInt();
        if (num < 3) {
            System.err.println("\033[1mInput Error\033[0m");
            System.exit(1);
        }

        int max = 0, min = 1000000, sum = 0;
        for (int i = 0; i < num; ++i) {
            System.out.print("Enter number: ");
            int cur = sc.nextInt();

            sum += cur;
            if (cur > max)
                max = cur;
            else if (cur < min)
                min = cur;
        }

        int range = max - min;
        double average = (double) sum / num;

        System.out.println("Minimum: " + min);
        System.out.println("Maximum: " + max);
        System.out.println("Range: " + range);
        System.out.println("Average: " + average);

        boolean isPrime = true;
        for (int i = 2; i < max / 2; ++i) {
            if (max % i == 0) { // clean result
                // not prime
                isPrime = false;
                break;
            }
        }

        System.out.println("Is the maximum a prime? " + isPrime);

        sc.close();
        return;
    }
}
