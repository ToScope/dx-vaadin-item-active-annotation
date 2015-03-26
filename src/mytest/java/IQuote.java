package mytest.java;

import java.util.Date;

public interface IQuote {

	public abstract Date getCreated();

	public abstract void setCreated(Date created);

	public abstract double getTotalPrice();

	public abstract void setTotalPrice(double totalPrice);

	public abstract String getTitle();

	public abstract void setTitle(String title);

}