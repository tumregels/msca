import copy

from pandas import DataFrame


def convert_to_matrix(x, debug=False):
    max_len = 0
    matrix = []
    for line in x.strip().splitlines():
        list_ = line.split()
        length = len(list_)
        if length > max_len:
            max_len = length
        elif length < max_len:
            for i in range(max_len - length):
                list_.insert(0, 0)
        matrix.append(list_)

    if debug:
        print(DataFrame(matrix).to_string())
    return matrix


def join_matrixes(m1, m2, debug=False):
    # set the smallest matrix as m1
    if len(m1) > len(m2):
        m2, m1 = m1, m2
    m3 = copy.deepcopy(m1)

    for r, l in enumerate(m1, start=1):
        for c, item in enumerate(l, start=1):
            # print(r,c, item, m2[r-1][c-1])
            if isinstance(m1[r - 1][c - 1], int):
                pass
            elif isinstance(m1[r - 1][c - 1], tuple):
                m3[r - 1][c - 1] = (*m1[r - 1][c - 1], *m2[r - 1][c - 1])
            elif isinstance(m1[r - 1][c - 1], str):
                m3[r - 1][c - 1] = (m1[r - 1][c - 1], m2[r - 1][c - 1])

    if debug:
        print(DataFrame(m3).to_string())
    return m3


def main():
    N1 = """
    TI	C1	C1	T1	C1	C1	T2	C4	C6
    	C2	C2	C1	C2	C2	C1	C2	C6
    		C2	C1	C2	C2	C1	C2	C6
    			T1	C1	C1	T2	C4	C6
    				C2	C1	C1	C2	C6
    					T2	C1	C3	C6
    						C2	C3	C6
    							C5	C7
    								C8
    """

    N2 = """
    TI C0201 C0301     TG  C0501  C0601     TG   C0801 C0901 Lame_V
       C0202 C0302  C0402  C0502  C0602  C0702   C0802 C0902 Lame_V
             C0303  C0403  C0503  C0603  C0703   C0803 C0903 Lame_V
                       TG  C0504  C0604     TG   C0804 C0904 Lame_V
                           C0505  C0605  C0705   C0805 C0905 Lame_V
                                     TG  C0706   C0806 C0906 Lame_V
                                         C0707   C0807 C0907 Lame_V
                                                 C0808 C0908 Lame_V
                                                       C0909 Lame_V
                                                             Lame_C
    """

    n1 = convert_to_matrix(N1, debug=True)
    n2 = convert_to_matrix(N2, debug=True)
    join_matrixes(n1, n2, debug=True)


if __name__ == '__main__':
    main()
