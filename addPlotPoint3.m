function addPlotPoint3(axis, hit)
    a = hit.IntersectionPoint;
    h = findobj(axis,'Type','line');
    x=get(h,'Xdata');
    y=get(h,'Ydata');
    cla(axis);
    plot([x a(1)], [y a(2)], 'd')
end
