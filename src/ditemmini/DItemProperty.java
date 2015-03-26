package ditemmini;

import com.vaadin.data.Property;
import com.vaadin.data.util.AbstractProperty;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

@SuppressWarnings("all")
public class DItemProperty<T extends Object> extends AbstractProperty<T> {
  private final Function0<? extends T> getter;
  
  private final Procedure1<? super T> setter;
  
  /**
   * Data type of the Property's value.
   */
  private final Class<T> type;
  
  public DItemProperty(final T value, final Class<T> type, final Function0<? extends T> getter, final Procedure1<? super T> setter) {
    this.getter = getter;
    this.setter = setter;
    this.setValue(value);
    this.type = type;
  }
  
  public DItemProperty(final T value, final Function0<? extends T> getter, final Procedure1<? super T> setter) {
    this(value, ((Class<T>) value.getClass()), getter, setter);
  }
  
  @Override
  public Class<? extends T> getType() {
    return this.type;
  }
  
  @Override
  public T getValue() {
    return this.getter.apply();
  }
  
  @Override
  public void setValue(final T value) throws Property.ReadOnlyException {
    this.setter.apply(value);
    this.fireValueChange();
  }
}
