import plotly as plt

"""
Class handles the construction of graphs for use on a html page primarily but can convert it to image if needed

"""
class GraphBuilderService:
    def __init__(self):
        pass

    def draw_bar_chart(self, x, y, title, x_label, y_label):
        fig = plt.graph_objs.Figure(plt.graph_objs.Bar(x=x, y=y))
        fig.update_layout(title=title, xaxis_title=x_label, yaxis_title=y_label)
        return fig

    def draw_line_chart(self, x, y, title, x_label, y_label):
        fig = plt.graph_objs.Figure(plt.graph_objs.Line(x=x, y=y))
        fig.update_layout(title=title, xaxis_title=x_label, yaxis_title=y_label)
        return fig

    def draw_scatter_plot(self, x, y, title, x_label, y_label):
        fig = plt.graph_objs.Figure(plt.graph_objs.Scatter(x=x, y=y))
        fig.update_layout(title=title, xaxis_title=x_label, yaxis_title=y_label)
        return fig

    def draw_pie_chart(self, labels, values, title):
        fig = plt.graph_objs.Figure(plt.graph_objs.Pie(labels=labels, values=values))
        fig.update_layout(title=title)
        return fig

    def convert_to_image(self, fig):
        return fig.to_image(format="png")

    def save_to_html(self, fig, file_path):
        fig.write_html(file_path)
