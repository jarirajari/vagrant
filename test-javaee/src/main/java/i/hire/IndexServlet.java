package i.hire;

import i.hire.ejb.GreeterEJB;

import java.io.IOException;
import java.io.PrintWriter;

import javax.inject.Inject;
import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name="IndexServlet", displayName="Index Servlet", urlPatterns = {"/"}, loadOnStartup=1)
public class IndexServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	@Inject
	private GreeterEJB greeter;
	
    @Override
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	
        try (PrintWriter out = response.getWriter()) {
            final String username = request.getParameter("username");
            if (username != null && username.length()> 0) {
                out.println("<html><h1>" + greeter.greet(username) + "</h1></html>");
            } else {
				out.println("<html><h3>" + "No username! Use 'username' GET parameter!" + "</h3></html>");
			}
        }
    }
}
