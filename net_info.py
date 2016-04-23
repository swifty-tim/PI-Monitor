#!/usr/bin/python

import os
from datetime import datetime

from urllib2 import Request, urlopen
import json

import pandas as pd
import numpy as np

from bokeh.models import Range1d, BoxAnnotation
from bokeh.plotting import figure, output_file, show, save
from bokeh.palettes import Spectral7

REQUEST_STRING = 'http://timothybarnard.org/Network/get.php?type=1'
TIME_FREQUENCY = '15T'  # T for minutes
GRAPH_SAVE_DIR_PATH = ''


def load_data(request_string):
    request = Request(request_string)
    response = urlopen(request)
    net_info = response.read()

    if len(net_info) < 1:
        raise ValueError('Empty data set returned from: {}'.format(REQUEST_STRING))

    data = json.loads(net_info)
    data_frame = pd.DataFrame(data['network'])
    return data_frame


def get_avg_ping_plot_by_time(averages_data):
    plot = figure(title="Ping over time", plot_width=1600, plot_height=800, x_axis_type="datetime")
    plot.y_range = Range1d(30, 120)
    plot.xaxis.axis_label = "Time(per 10 mins)"
    plot.yaxis.axis_label = "Ping(ms)"

    plot.line(x=averages_data.test_date, y=averages_data.ping, legend='ping', line_color='blue', line_width=2)
    plot.circle(x=averages_data.test_date, y=averages_data.ping, fill_color="white", line_color="blue", size=6)

    low_box = BoxAnnotation(plot=plot, top=60, fill_alpha=0.1, fill_color='green')
    mid_box = BoxAnnotation(plot=plot, bottom=60, top=90, fill_alpha=0.1, fill_color='yellow')
    high_box = BoxAnnotation(plot=plot, bottom=90, fill_alpha=0.1, fill_color='red')
    plot.renderers.extend([low_box, mid_box, high_box])
    return plot


def get_time_segment_ping_averages(data, frequency):
    averages = pd.DataFrame({'ping': data.ping_avg.tolist()}, index=data.test_date)
    averages = averages.groupby(pd.TimeGrouper(freq=frequency)).aggregate(np.mean)
    return averages.reset_index()


def get_ping_plot_by_host(data):
    data.drop(['id', 'net_type', 'packet_loss', 'ping_max', 'ping_min', 'upload', 'ping_loc', 'ip_address',
               'ping', 'hosted_by', 'download'], axis=1, inplace=True)

    plot = figure(title="Ping over time", plot_width=1600, plot_height=800, x_axis_type="datetime")
    plot.y_range = Range1d(0, 150)
    plot.xaxis.axis_label = "Time(per 10 mins)"
    plot.yaxis.axis_label = "Ping(ms)"

    dic = {x: data.ping_avg[data.hostname == x] for x in data.hostname.unique()}
    dix = {x: data.test_date[data.hostname == x] for x in data.hostname.unique()}

    i = 0
    for host in data.hostname.unique().tolist():
        plot.line(x=dix[host].values, y=dic[host].values, line_width=2, line_color=Spectral7[i], legend=host)
        plot.circle(x=dix[host].values, y=dic[host].values, fill_color="white", size=6)
        i += 1

    low_box = BoxAnnotation(plot=plot, top=60, fill_alpha=0.1, fill_color='green')
    mid_box = BoxAnnotation(plot=plot, bottom=60, top=90, fill_alpha=0.1, fill_color='yellow')
    high_box = BoxAnnotation(plot=plot, bottom=90, fill_alpha=0.1, fill_color='red')
    plot.renderers.extend([low_box, mid_box, high_box])
    return plot


def convert_columns(data):
    data.test_date = pd.to_datetime(data.test_date)
    data.ping_avg = data.ping_avg.apply(float)
    return data


def get_all_plots(net_info, time_frequency):
    plot_dictionary = {}
    averages = get_time_segment_ping_averages(net_info, time_frequency)
    plot_dictionary['avg_ping_plot_by_time'] = get_avg_ping_plot_by_time(averages)
    plot_dictionary['ping_plot_by_host'] = get_ping_plot_by_host(net_info)
    return plot_dictionary


def save_plots_to_dir(plot_dictionary, dir_path):
    date_time_str = datetime.now().strftime('_%Y%m%d_%H%M')

    if dir_path != '' and not os.path.exists(dir_path):
        os.makedirs(dir_path)

    for plot_name, plot in plot_dictionary.iteritems():
        file_name = ''.join([plot_name, date_time_str, '.html'])
        file_path = os.path.join(dir_path, file_name)
        output_file(file_path)
        save(plot)


def main():
    request_string = REQUEST_STRING
    time_frequency = TIME_FREQUENCY
    dir_path = GRAPH_SAVE_DIR_PATH

    net_info = load_data(request_string)
    net_info = convert_columns(net_info)

    plot_dictionary = get_all_plots(net_info, time_frequency)
    save_plots_to_dir(plot_dictionary, dir_path)

if __name__ == "__main__":
    main()
