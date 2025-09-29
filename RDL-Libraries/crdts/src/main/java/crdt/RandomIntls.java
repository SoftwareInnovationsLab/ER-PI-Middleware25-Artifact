import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Random;
import java.util.Set;

public class RandomIntls {
    public static void main(String[] args) {
        List<String> events = readEventsFromFile("InitRun/events.facts");
        Set<String> visitedPaths = new HashSet<>();
        randomInterleave(events, visitedPaths, new Random());
    }

    public static void randomInterleave(List<String> events, Set<String> visitedPaths, Random random) {
        int n = events.size();
        while (visitedPaths.size() < factorial(n)) {
            List<String> shuffledEvents = new ArrayList<>(events);
            for (int i = 0; i < n; i++) {
                int randomIndex = random.nextInt(n);
                String temp = shuffledEvents.get(i);
                shuffledEvents.set(i, shuffledEvents.get(randomIndex));
                shuffledEvents.set(randomIndex, temp);
            }

            String path = String.join(",", shuffledEvents);

            if (!visitedPaths.contains(path)) {
                visitedPaths.add(path);
                System.out.println(shuffledEvents);
            }
        }
    }

    public static long factorial(int n) {
        long result = 1;
        for (int i = 2; i <= n; i++) {
            result *= i;
        }
        return result;
    }

    public static List<String> readEventsFromFile(String filename) {
        List<String> events = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(filename))) {
            String line;
            while ((line = br.readLine()) != null) {
                events.add(line.trim());
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return events;
    }
}
