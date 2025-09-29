package crdt;

import crdt.sets.TwoPSet;
import java.util.Set;
import java.util.HashSet;
import java.util.List;
import java.util.ArrayList;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import org.junit.Test;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.lang.reflect.Proxy;
import java.lang.reflect.InvocationHandler;
import java.util.concurrent.TimeUnit;

public class Main {

    public static void PrintSet(TwoPSet<Integer> set) {
        Set<Integer> resultSet = set.get();

        System.out.println("Elements in the set:");
        for (Integer item : resultSet) {
            System.out.println(item);
        }
        System.out.println();
    }

    public static void assertOrderConsistency(TwoPSet<Integer> set1, TwoPSet<Integer> set2) {
        List<Integer> list1 = new ArrayList<Integer>(set1.get());
        List<Integer> list2 = new ArrayList<Integer>(set2.get());

        assertEquals(list1, list2);
    }

    public static void assertNoDuplicationAfterMoving(TwoPSet<Integer> set, int fromIndex, int toIndex) {
        List<Integer> copyList = new ArrayList<Integer>(set.get());
        Integer movedItem = copyList.remove(fromIndex);
        copyList.add(toIndex, movedItem);
        // Size remains the same
        assertEquals(set.get().size(), copyList.size());
        // Assert contents haven't changed
        assertTrue(set.get().containsAll(copyList));
    }

    public static void Delay(int seconds) {
        try {
            TimeUnit.SECONDS.sleep(seconds);
        } catch (InterruptedException ie) {
            Thread.currentThread().interrupt();
        }
    }

    public static void Persist_Proxy(String[] contents) {
        String directoryPath = "Events";
        String fileName = "events.facts";
        String filePath = directoryPath + File.separator + fileName;

        File directory = new File(directoryPath);
        if (!directory.exists()) {
            directory.mkdirs();
        }

        File file = new File(filePath);
        try {
            file.createNewFile();
        } catch (IOException e) {
            e.printStackTrace();
        }

        try (FileWriter fw = new FileWriter(file, true); // true for append mode
             BufferedWriter bw = new BufferedWriter(fw)) {
            for (int i = 0; i < contents.length; i++) {
                bw.write(contents[i]);
                if (i < contents.length - 1) {
                    bw.write("_");
                }
            }
            bw.write("\n");
            bw.flush();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void Do_Actions(boolean flag, TwoPSet<Integer> set1, TwoPSet<Integer> set2, String[] update_info) {
        if ("add".equals(update_info[0])) {
            int intValue = Integer.parseInt(update_info[1]);
            if ("1".equals(update_info[2])) {
                set1.add(intValue);
            } else {
                set2.add(intValue);
            }
        } else if ("remove".equals(update_info[0])) {
            int intValue = Integer.parseInt(update_info[1]);
            if ("1".equals(update_info[2])) {
                set1.remove(intValue);
            } else {
                set2.remove(intValue);
            }
        } else {
            // System.out.println("Executing Merge Function");
            if ("1".equals(update_info[1])) {
                set1.merge(set2);
            } else {
                set2.merge(set1);
            }
        }
        if (flag == true) {
            Persist_Proxy(update_info);
        }
    }

    public static void main(String[] args) {
        String initPath = "InitRun/";
        String directoryPath = "interleavings/";
        File directory = new File(directoryPath);

        TwoPSet<Integer> set1 = new TwoPSet<Integer>();
        TwoPSet<Integer> set2 = new TwoPSet<Integer>();

        for (int i = 0; i <= 30; i++) {
            if (i == 0) {
                File file = new File(initPath + "events.facts");
                if (file.isFile()) {
                    try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
                        String line;
                        while ((line = reader.readLine()) != null) {
                            String[] update_info = line.split("_");
                            Do_Actions(true, set1, set2, update_info);
                        }
                    }  catch (IOException e) {
                        System.err.println("Error reading file: " + file.getName());
                        e.printStackTrace();
                    }
                }
                System.out.println("Events invocations are done");
                Delay(60);
            }
            else {
                File file = new File(directoryPath + "ils_" + i + ".txt");
                if (file.isFile()) {
                    // System.out.println("Reading file: " + file.getName());
                    System.out.println("## Running interleaving: " + i + " ##");
                    try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
                        String line;
                        while ((line = reader.readLine()) != null) {
                            // System.out.println(line);
                            String[] update_info = line.split("_");
                            Do_Actions(false, set1, set2, update_info);
                        }
                        PrintSet(set1);
                        PrintSet(set2);
//                        assertOrderConsistency(set1, set2);
//                        assertNoDuplicationAfterMoving(set1, 0, set1.get().size());
//                        assertNoDuplicationAfterMoving(set2, 0, set2.get().size());
                        System.out.println("## End interleaving: " + i + " ##");
                    } catch (IOException e) {
                        System.err.println("Error reading file: " + file.getName());
                        e.printStackTrace();
                    }
                    System.out.println(); // Add a blank line between files
                }
                else {
                    System.err.println("File does not exist");
                }
            }
            Delay(20);
        }

        

        // // Create an instance of TwoPSet
        // TwoPSet<String> original = new TwoPSet<>();

        // // Create an instance of the InvocationHandler
        // TwoPSetInvocationHandler<String> handler = new TwoPSetInvocationHandler<>(original);

        // // Create a proxy instance that implements TwoPSetProxy
        // TwoPSetProxy<String> proxy = (TwoPSetProxy<String>) Proxy.newProxyInstance(
        //         TwoPSet.class.getClassLoader(),
        //         new Class<?>[]{TwoPSetProxy.class},
        //         handler);

        // // Use the proxy
        // proxy.add("item1");
        // proxy.add("item2");
        // proxy.remove("item1");
        // Set<String> result = proxy.get();
        // Add more method calls as needed
    }
}
