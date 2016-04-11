package i.hire.ejb;

import static org.junit.Assert.*;

import org.junit.Test;

public class GreeterEJBTest {
	
	@Test
	public void aBadTest() {
		GreeterEJB ejb = new GreeterEJB();
		
		assertEquals("Hello, John Doe!", ejb.greet("John Doe"));
	}
}
