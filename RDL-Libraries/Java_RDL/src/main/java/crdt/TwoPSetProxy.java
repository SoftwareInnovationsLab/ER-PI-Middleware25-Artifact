package crdt;

import java.util.Set;

public interface TwoPSetProxy<T> {
    void add(T item);
    void remove(T item);
    Set<T> get();
    void merge(TwoPSetProxy<T> set);
    TwoPSetProxy<T> copy();
}
