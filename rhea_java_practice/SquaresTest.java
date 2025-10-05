import java.util.Scanner;

public class SquaresTest {
    static int countDigits(int num) {
        int res = 0;
        do {
            num /= 10;
            res++;
        } while (num != 0);
        return res;
    }

    static int pow(int num, int exp) {
        int res = 1;
        for (int i = 0; i < exp; ++i) {
            res *= num;
        }
        return res;
    }

    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);

        System.out.println("Eason Qin");

        int num;
        do {
            System.out.print("Enter a number less than 10: ");
            num = sc.nextInt();

            if (num < 1 || num >= 10) {
                System.err.println(">>> Error please enter again");
            }
        } while (num < 1 || num >= 10);

        int maxLen = countDigits(pow(num, num));
        maxLen += (maxLen - 1) / 3;
        for (int cur = 1; cur <= num; ++cur) {
            // (1~num)^1
            System.out.print(cur + " ");

            // (1~num)^2
            if (cur * cur < 10) {
                System.out.print(" ");
            }
            System.out.print(cur * cur + " ");

            // (1~num)^num
            int lastVal = pow(num, cur);
            int lastValLen = countDigits(lastVal);
            // barbaric aah string manipulation
            int digits = 1;
            int temp = lastVal;
            String buf = "";
            do {
                int digit = temp % 10;
                buf = digit + buf;
                if (digits % 3 == 0 && lastValLen != digits) {
                    buf = ',' + buf;
                }
                temp /= 10;
                digits++;
            } while (temp != 0);

            int padding = maxLen - buf.length(); // in the sample output, the size
                                                 // of the
            // last column is never >11
            for (int i = 0; i < padding; ++i)
                System.out.print(" ");

            System.out.println(buf);
        }
        sc.close();
    }
}
