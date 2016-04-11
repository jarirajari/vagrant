package i.hire.ejb;

import javax.ejb.Stateless;

@Stateless
public class GreeterEJB {

    public String greet(String name) {
        return String.format("Hello, %s!", name);
    }
}
