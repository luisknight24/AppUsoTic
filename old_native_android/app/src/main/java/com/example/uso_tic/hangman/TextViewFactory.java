package com.example.uso_tic.hangman;
import com.example.uso_tic.R;
import android.content.Context;
import android.os.Build;
import android.util.TypedValue;
import android.view.ViewGroup;
import android.widget.TableRow;
import android.widget.TextView;
public class TextViewFactory {

    private final Context context;

    public TextViewFactory(Context context)
    {
        this.context = context;
    }

    public TextView createTextView(int id)
    {
        TextView textView = new TextView(context);
        textView.setId(id);
        textView.setText(context.getResources().getText(R.string.empty_char));
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            textView.setTextColor(context.getResources().getColor(R.color.colorPrimaryText, context.getTheme()));
        }
        textView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 35);
        textView.setLayoutParams(getLayoutParams());

        return textView;
    }


    private ViewGroup.MarginLayoutParams getLayoutParams()
    {
        int marginStart = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 6, context.getResources().getDisplayMetrics());
        int marginEnd = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 8, context.getResources().getDisplayMetrics());
        int marginBottom = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 3, context.getResources().getDisplayMetrics());

        TableRow.LayoutParams layoutParams = new TableRow.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT);

        layoutParams.setMargins(marginStart, 0, marginEnd, marginBottom);
        return layoutParams;
    }

}
