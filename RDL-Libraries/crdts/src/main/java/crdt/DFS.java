import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class DFS {
    public static void main(String[] args) {
        List<String> events = readEventsFromFile("InitRun/events.facts");
        dfs(new ArrayList<String>(), events, new HashSet<String>());
    }

    public static void dfs(List<String> path, List<String> remainingEvents, Set<String> visitedPaths) {
        if (remainingEvents.isEmpty()) {
            System.out.println(path);
            return;
        }

        for (int i = 0; i < remainingEvents.size(); i++) {
            List<String> newPath = new ArrayList<>(path);
            List<String> newRemaining = new ArrayList<>(remainingEvents);

            newPath.add(remainingEvents.get(i));
            newRemaining.remove(i);

            String newPathString = String.join(",", newPath);

            if (!visitedPaths.contains(newPathString)) {
                visitedPaths.add(newPathString);
                dfs(newPath, newRemaining, visitedPaths);
            }
        }
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
