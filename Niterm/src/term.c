#include <dirent.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/wait.h>
#include <termios.h>
#include <unistd.h>
#define TERMUX_UNUSED(x) x __attribute__((__unused__))
#ifdef __APPLE__
#define LACKS_PTSNAME_R
#endif

//这是回调java的方法，用来报错
// static int throw_runtime_exception(JNIEnv* env, char const* message)
// {
//     jclass exClass = (*env)->FindClass(env, "java/lang/RuntimeException");
//     (*env)->ThrowNew(env, exClass, message);
//     return -1;
// }
//这个方法用来创建一个进程
//cmd  执行程序
//cwd  当前工作目录
//argv 参数，类似于["-i","-c"]

int create_ptm(
    int rows,
    int columns, char *ptsPath)
{
    //调用open这个路径会随机获得一个大于0的整形值
    int ptm = open("/dev/ptmx", O_RDWR | O_CLOEXEC);
    //这个值会从0依次上增
    // if (ptm < 0) return throw_runtime_exception(env, "Cannot open /dev/ptmx");
#ifdef LACKS_PTSNAME_R
    char *devname;
#else
    char devname[64];
#endif
    if (grantpt(ptm) || unlockpt(ptm) ||
#ifdef LACKS_PTSNAME_R
        (devname = ptsname(ptm)) == NULL
#else
        ptsname_r(ptm, devname, sizeof(devname))
#endif
    )
    {
        // return throw_runtime_exception(env, "Cannot grantpt()/unlockpt()/ptsname_r() on /dev/ptmx");
    }
    for (int i = 0; i < sizeof(devname); i++)
    {
        ptsPath[i] = devname[i];
    }
    // Enable UTF-8 mode and disable flow control to prevent Ctrl+S from locking up the display.
    struct termios tios;
    tcgetattr(ptm, &tios);
    tios.c_iflag |= IUTF8;
    tios.c_iflag &= ~(IXON | IXOFF);
    tcsetattr(ptm, TCSANOW, &tios);

    /** Set initial winsize. */
    struct winsize sz = {.ws_row = (unsigned short)rows, .ws_col = (unsigned short)columns};
    ioctl(ptm, TIOCSWINSZ, &sz);
    return ptm;
}
void create_subprocess(char *env,
                       char const *cmd,
                       char const *cwd,
                       char *const argv[],
                       char **envp,
                       int *pProcessId,
                       int ptmfd)
{
#ifdef LACKS_PTSNAME_R
    char *devname;
#else
    char devname[64];
#endif

#ifdef LACKS_PTSNAME_R
    devname = ptsname(ptmfd);
#else
    ptsname_r(ptmfd, devname, sizeof(devname));
#endif
    //创建一个进程，返回是它的pid
    pid_t pid = fork();
    if (pid < 0)
    {
        // return throw_runtime_exception(env, "Fork failed");
    }
    else if (pid > 0)
    {
        *pProcessId = (int)pid;
    }
    else
    {
        // Clear signals which the Android java process may have blocked:
        sigset_t signals_to_unblock;
        sigfillset(&signals_to_unblock);
        sigprocmask(SIG_UNBLOCK, &signals_to_unblock, 0);

        close(ptmfd);
        setsid();
        //O_RDWR读写,devname为/dev/pts/0,1,2,3...
        int pts = open(devname, O_RDWR);
        if (pts < 0)
            exit(-1);
        //下面三个大概将stdin,stdout,stderr复制到了这个pts里面
        //ptmx,pts pseudo terminal master and slave
        dup2(pts, 0);
        dup2(pts, 1);
        dup2(pts, 2);
        //Linux的api,打开一个文件夹
        DIR *self_dir = opendir("/proc/self/fd");
        if (self_dir != NULL)
        {
            //dirfd没查到，好像把文件夹转换为文件描述符
            int self_dir_fd = dirfd(self_dir);
            struct dirent *entry;
            while ((entry = readdir(self_dir)) != NULL)
            {
                int fd = atoi(entry->d_name);
                if (fd > 2 && fd != self_dir_fd)
                    close(fd);
            }
            closedir(self_dir);
        } //清除环境变量
        clearenv();

        if (envp)
            for (; *envp; ++envp)
                putenv(*envp);

        if (chdir(cwd) != 0)
        {
            char *error_message;
            // No need to free asprintf()-allocated memory since doing execvp() or exit() below.
            if (asprintf(&error_message, "chdir(\"%s\")", cwd) == -1)
                error_message = "chdir()";
            perror(error_message);
            fflush(stderr);
        }
        //执行程序
        execvp(cmd, argv);

        // Show terminal output about failing exec() call:
        char *error_message;
        if (asprintf(&error_message, "exec(\"%s\")", cmd) == -1)
            error_message = "exec()";
        perror(error_message);
        _exit(1);
    }
}
void write_to_fd(int fd, char *str)
{
    write(fd, str, strlen(str));
}
char *get_output_from_fd(int fd)
{
    int flag = -1;
    flag = fcntl(fd, F_GETFL); //获取当前flag
    flag |= O_NONBLOCK;        //设置新falg
    fcntl(fd, F_SETFL, flag);  //更新flag
    //动态申请空间
    char *str = (char *)malloc((4097) * sizeof(char));
    //read函数返回从fd中读取到字符的长度
    //读取的内容存进str,4096表示此次读取4096个字节，如果只读到10个则length为10
    int length = read(fd, str, 4096);
    if (length == -1)
    {
        free(str);
        return NULL;
    }
    else
    {
        str[length] = '\0';
        return str;
    }
}
char *getFilePathFromFd(int fd)
{
    // char buf[1024] = {'\0'};
    // char file_path[1024] = {'\0'};
    // snprintf(buf, sizeof(buf), "/proc/self/fd/%d", fd);
    // readlink(buf, file_path, sizeof(file_path) - 1);

    // printf("%s\n", file_path);
    // char *newPath;
    // newPath = (char **)malloc((11) * sizeof(char *));
    // newPath = file_path;
    // newPath[10] = '\0';
    return ptsname(fd);
}
// int Niterm_createSubprocess(char const *cmd,
//                             char const *cwd,
//                             char *const argv[],
//                             char **envp,
//                             int *pProcessId)
// {
//     int ptm = create_subprocess("", cmd, cwd, argv, envp, pProcessId);
//     return ptm;
// }

//设置虚拟终端的宽高
//ioctl控制io的控制器
void Niterm_setPtyWindowSize()
{
}
void Niterm_setPtyUTF8Mode()
{
}
void Niterm_close()
{
}
int Niterm_waitFor()
{
}
// JNIEXPORT jint JNICALL Java_com_termux_terminal_JNI_createSubprocess(
//         JNIEnv* env,
//         jclass TERMUX_UNUSED(clazz),
//         jstring cmd,
//         jstring cwd,
//         jobjectArray args,
//         jobjectArray envVars,
//         jintArray processIdArray,
//         jint rows,
//         jint columns)
// {
//     jsize size = args ? (*env)->GetArrayLength(env, args) : 0;
//     char** argv = NULL;
//     if (size > 0) {
//         argv = (char**) malloc((size + 1) * sizeof(char*));
//         if (!argv) return throw_runtime_exception(env, "Couldn't allocate argv array");
//         for (int i = 0; i < size; ++i) {
//             jstring arg_java_string = (jstring) (*env)->GetObjectArrayElement(env, args, i);
//             char const* arg_utf8 = (*env)->GetStringUTFChars(env, arg_java_string, NULL);
//             if (!arg_utf8) return throw_runtime_exception(env, "GetStringUTFChars() failed for argv");
//             argv[i] = strdup(arg_utf8);
//             (*env)->ReleaseStringUTFChars(env, arg_java_string, arg_utf8);
//         }
//         argv[size] = NULL;
//     }

//     size = envVars ? (*env)->GetArrayLength(env, envVars) : 0;
//     char** envp = NULL;
//     if (size > 0) {
//         envp = (char**) malloc((size + 1) * sizeof(char *));
//         if (!envp) return throw_runtime_exception(env, "malloc() for envp array failed");
//         for (int i = 0; i < size; ++i) {
//             jstring env_java_string = (jstring) (*env)->GetObjectArrayElement(env, envVars, i);
//             char const* env_utf8 = (*env)->GetStringUTFChars(env, env_java_string, 0);
//             if (!env_utf8) return throw_runtime_exception(env, "GetStringUTFChars() failed for env");
//             envp[i] = strdup(env_utf8);
//             (*env)->ReleaseStringUTFChars(env, env_java_string, env_utf8);
//         }
//         envp[size] = NULL;
//     }

//     int procId = 0;
//     char const* cmd_cwd = (*env)->GetStringUTFChars(env, cwd, NULL);
//     char const* cmd_utf8 = (*env)->GetStringUTFChars(env, cmd, NULL);
//     int ptm = create_subprocess(env, cmd_utf8, cmd_cwd, argv, envp, &procId, rows, columns);
//     (*env)->ReleaseStringUTFChars(env, cmd, cmd_utf8);
//     (*env)->ReleaseStringUTFChars(env, cmd, cmd_cwd);

//     if (argv) {
//         for (char** tmp = argv; *tmp; ++tmp) free(*tmp);
//         free(argv);
//     }
//     if (envp) {
//         for (char** tmp = envp; *tmp; ++tmp) free(*tmp);
//         free(envp);
//     }

//     int* pProcId = (int*) (*env)->GetPrimitiveArrayCritical(env, processIdArray, NULL);
//     if (!pProcId) return throw_runtime_exception(env, "JNI call GetPrimitiveArrayCritical(processIdArray, &isCopy) failed");

//     *pProcId = procId;
//     (*env)->ReleasePrimitiveArrayCritical(env, processIdArray, pProcId, 0);

//     return ptm;
// }

// JNIEXPORT void JNICALL Java_com_termux_terminal_JNI_setPtyWindowSize(JNIEnv* TERMUX_UNUSED(env), jclass TERMUX_UNUSED(clazz), jint fd, jint rows, jint cols)
// {
//     struct winsize sz = { .ws_row = (unsigned short) rows, .ws_col = (unsigned short) cols };
//     ioctl(fd, TIOCSWINSZ, &sz);
// }

// JNIEXPORT void JNICALL Java_com_termux_terminal_JNI_setPtyUTF8Mode(JNIEnv* TERMUX_UNUSED(env), jclass TERMUX_UNUSED(clazz), jint fd)
// {
//     struct termios tios;
//     tcgetattr(fd, &tios);
//     if ((tios.c_iflag & IUTF8) == 0) {
//         tios.c_iflag |= IUTF8;
//         tcsetattr(fd, TCSANOW, &tios);
//     }
// }

// JNIEXPORT jint JNICALL Java_com_termux_terminal_JNI_waitFor(JNIEnv* TERMUX_UNUSED(env), jclass TERMUX_UNUSED(clazz), jint pid)
// {
//     int status;
//     waitpid(pid, &status, 0);
//     if (WIFEXITED(status)) {
//         return WEXITSTATUS(status);
//     } else if (WIFSIGNALED(status)) {
//         return -WTERMSIG(status);
//     } else {
//         // Should never happen - waitpid(2) says "One of the first three macros will evaluate to a non-zero (true) value".
//         return 0;
//     }
// }

// JNIEXPORT void JNICALL Java_com_termux_terminal_JNI_close(JNIEnv* TERMUX_UNUSED(env), jclass TERMUX_UNUSED(clazz), jint fileDescriptor)
// {
//     close(fileDescriptor);
// }
