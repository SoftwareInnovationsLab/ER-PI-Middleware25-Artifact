package crdt;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.util.Set;
import crdt.sets.TwoPSet;

public class TwoPSetInvocationHandler<T> implements InvocationHandler {
    private TwoPSet<T> target;

    public TwoPSetInvocationHandler(TwoPSet<T> target) {
        this.target = target;
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        try {
            // Intercept method calls
            if (method.getName().equals("add")) {
                // System.out.println("proxy add gets called");
                target.add((T) args[0]);
            } else if (method.getName().equals("remove")) {
                target.remove((T) args[0]);
            } else if (method.getName().equals("get")) {
                return target.get();
            } else if (method.getName().equals("merge")) {
                target.merge((TwoPSet<T>) args[0]);
            } else if (method.getName().equals("copy")) {
                return target.copy();
            }
            return null;
        } catch (Exception e) {
            throw new RuntimeException("Error invoking method: " + method.getName(), e);
        }
    }
}
