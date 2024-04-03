import java.util.Random;

public class LABA2 {
    static private int TredCount = 5;
    static private int Elemets = 100000;

    static private int[] elem = new int[Elemets];

    volatile static private int tempMin = 0;

    static private int CountOfPart = Elemets / TredCount;

    public static void main(String[] args) {
        ArrayInit();

        Thread[] threads = new Thread[TredCount];

        for (int i = 0; i < TredCount; i++) {
            final int finalI = i;
            threads[i] = new Thread(() -> Calculate(finalI));
            threads[i].start();
        }

        for (Thread threadForJoin : threads) {
            try {
                threadForJoin.join();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }

        System.out.println("MyMin is " + elem[tempMin]);
        System.out.println("Index is " + tempMin);
    }

    static void Calculate(Object a) {
        int idStart = (int) a * CountOfPart;
        int idEnd = ((int) a + 1) * CountOfPart - 1;

        for (int i = idStart; i <= idEnd; i++) {
                if (elem[i] < elem[tempMin])
                    tempMin = i;
        }
    }

    static void ArrayInit() {
        Random rnd = new Random();
        for (int i = 0; i < Elemets; i++) {
            elem[i] = rnd.nextInt(0,Integer.MAX_VALUE);
        }

        int temp = rnd.nextInt(Elemets);
        elem[temp] = -1;
        System.out.println("Find this index = " + temp);
    }
}