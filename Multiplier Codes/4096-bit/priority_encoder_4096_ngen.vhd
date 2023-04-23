library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity priority_encoder_4096 is
generic(
  g_n:      integer := 4096;  -- Input (multiplier) length is n
  g_log2n:  integer := 12;  -- Base 2 Logarithm of input length n; i.e., output length
  g_q:      integer := 64;  -- q is the least power of 2 greater than sqrt(n); i.e., 2^(ceil(log_2(sqrt(n)))
  g_log2q:  integer := 6;  -- Base 2 Logarithm of q
  g_k:      integer := 64;  -- k is defined as n/q, if n is a perfect square, then k = sqrt(n) = q
  g_log2k:  integer := 6  -- Base 2 Logarithm of k
);
port(
  input: in std_logic_vector(g_n-1 downto 0);
  output: out std_logic_vector(g_log2n-1 downto 0)
);
end priority_encoder_4096;

architecture behavioral of priority_encoder_4096 is

component priority_encoder_64
port(
  input: in std_logic_vector(g_k - 1 downto 0);
  output: out std_logic_vector(g_log2k - 1 downto 0)
);
end component;

signal c_output: std_logic_vector(g_log2k - 1 downto 0); -- coarse encoder output, select input signal for mux
signal f_input: std_logic_vector(g_q - 1 downto 0); -- fine encoder input
signal slice_or: std_logic_vector(g_k - 1 downto 0); -- there should be `k` or gates with q inputs each. last is effectively unused

begin
slice_or(63) <= input(4095) or input(4094) or input(4093) or input(4092) or input(4091) or input(4090) or input(4089) or input(4088) or 
                input(4087) or input(4086) or input(4085) or input(4084) or input(4083) or input(4082) or input(4081) or input(4080) or 
                input(4079) or input(4078) or input(4077) or input(4076) or input(4075) or input(4074) or input(4073) or input(4072) or 
                input(4071) or input(4070) or input(4069) or input(4068) or input(4067) or input(4066) or input(4065) or input(4064) or 
                input(4063) or input(4062) or input(4061) or input(4060) or input(4059) or input(4058) or input(4057) or input(4056) or 
                input(4055) or input(4054) or input(4053) or input(4052) or input(4051) or input(4050) or input(4049) or input(4048) or 
                input(4047) or input(4046) or input(4045) or input(4044) or input(4043) or input(4042) or input(4041) or input(4040) or 
                input(4039) or input(4038) or input(4037) or input(4036) or input(4035) or input(4034) or input(4033) or input(4032);

slice_or(62) <= input(4031) or input(4030) or input(4029) or input(4028) or input(4027) or input(4026) or input(4025) or input(4024) or 
                input(4023) or input(4022) or input(4021) or input(4020) or input(4019) or input(4018) or input(4017) or input(4016) or 
                input(4015) or input(4014) or input(4013) or input(4012) or input(4011) or input(4010) or input(4009) or input(4008) or 
                input(4007) or input(4006) or input(4005) or input(4004) or input(4003) or input(4002) or input(4001) or input(4000) or 
                input(3999) or input(3998) or input(3997) or input(3996) or input(3995) or input(3994) or input(3993) or input(3992) or 
                input(3991) or input(3990) or input(3989) or input(3988) or input(3987) or input(3986) or input(3985) or input(3984) or 
                input(3983) or input(3982) or input(3981) or input(3980) or input(3979) or input(3978) or input(3977) or input(3976) or 
                input(3975) or input(3974) or input(3973) or input(3972) or input(3971) or input(3970) or input(3969) or input(3968);

slice_or(61) <= input(3967) or input(3966) or input(3965) or input(3964) or input(3963) or input(3962) or input(3961) or input(3960) or 
                input(3959) or input(3958) or input(3957) or input(3956) or input(3955) or input(3954) or input(3953) or input(3952) or 
                input(3951) or input(3950) or input(3949) or input(3948) or input(3947) or input(3946) or input(3945) or input(3944) or 
                input(3943) or input(3942) or input(3941) or input(3940) or input(3939) or input(3938) or input(3937) or input(3936) or 
                input(3935) or input(3934) or input(3933) or input(3932) or input(3931) or input(3930) or input(3929) or input(3928) or 
                input(3927) or input(3926) or input(3925) or input(3924) or input(3923) or input(3922) or input(3921) or input(3920) or 
                input(3919) or input(3918) or input(3917) or input(3916) or input(3915) or input(3914) or input(3913) or input(3912) or 
                input(3911) or input(3910) or input(3909) or input(3908) or input(3907) or input(3906) or input(3905) or input(3904);

slice_or(60) <= input(3903) or input(3902) or input(3901) or input(3900) or input(3899) or input(3898) or input(3897) or input(3896) or 
                input(3895) or input(3894) or input(3893) or input(3892) or input(3891) or input(3890) or input(3889) or input(3888) or 
                input(3887) or input(3886) or input(3885) or input(3884) or input(3883) or input(3882) or input(3881) or input(3880) or 
                input(3879) or input(3878) or input(3877) or input(3876) or input(3875) or input(3874) or input(3873) or input(3872) or 
                input(3871) or input(3870) or input(3869) or input(3868) or input(3867) or input(3866) or input(3865) or input(3864) or 
                input(3863) or input(3862) or input(3861) or input(3860) or input(3859) or input(3858) or input(3857) or input(3856) or 
                input(3855) or input(3854) or input(3853) or input(3852) or input(3851) or input(3850) or input(3849) or input(3848) or 
                input(3847) or input(3846) or input(3845) or input(3844) or input(3843) or input(3842) or input(3841) or input(3840);

slice_or(59) <= input(3839) or input(3838) or input(3837) or input(3836) or input(3835) or input(3834) or input(3833) or input(3832) or 
                input(3831) or input(3830) or input(3829) or input(3828) or input(3827) or input(3826) or input(3825) or input(3824) or 
                input(3823) or input(3822) or input(3821) or input(3820) or input(3819) or input(3818) or input(3817) or input(3816) or 
                input(3815) or input(3814) or input(3813) or input(3812) or input(3811) or input(3810) or input(3809) or input(3808) or 
                input(3807) or input(3806) or input(3805) or input(3804) or input(3803) or input(3802) or input(3801) or input(3800) or 
                input(3799) or input(3798) or input(3797) or input(3796) or input(3795) or input(3794) or input(3793) or input(3792) or 
                input(3791) or input(3790) or input(3789) or input(3788) or input(3787) or input(3786) or input(3785) or input(3784) or 
                input(3783) or input(3782) or input(3781) or input(3780) or input(3779) or input(3778) or input(3777) or input(3776);

slice_or(58) <= input(3775) or input(3774) or input(3773) or input(3772) or input(3771) or input(3770) or input(3769) or input(3768) or 
                input(3767) or input(3766) or input(3765) or input(3764) or input(3763) or input(3762) or input(3761) or input(3760) or 
                input(3759) or input(3758) or input(3757) or input(3756) or input(3755) or input(3754) or input(3753) or input(3752) or 
                input(3751) or input(3750) or input(3749) or input(3748) or input(3747) or input(3746) or input(3745) or input(3744) or 
                input(3743) or input(3742) or input(3741) or input(3740) or input(3739) or input(3738) or input(3737) or input(3736) or 
                input(3735) or input(3734) or input(3733) or input(3732) or input(3731) or input(3730) or input(3729) or input(3728) or 
                input(3727) or input(3726) or input(3725) or input(3724) or input(3723) or input(3722) or input(3721) or input(3720) or 
                input(3719) or input(3718) or input(3717) or input(3716) or input(3715) or input(3714) or input(3713) or input(3712);

slice_or(57) <= input(3711) or input(3710) or input(3709) or input(3708) or input(3707) or input(3706) or input(3705) or input(3704) or 
                input(3703) or input(3702) or input(3701) or input(3700) or input(3699) or input(3698) or input(3697) or input(3696) or 
                input(3695) or input(3694) or input(3693) or input(3692) or input(3691) or input(3690) or input(3689) or input(3688) or 
                input(3687) or input(3686) or input(3685) or input(3684) or input(3683) or input(3682) or input(3681) or input(3680) or 
                input(3679) or input(3678) or input(3677) or input(3676) or input(3675) or input(3674) or input(3673) or input(3672) or 
                input(3671) or input(3670) or input(3669) or input(3668) or input(3667) or input(3666) or input(3665) or input(3664) or 
                input(3663) or input(3662) or input(3661) or input(3660) or input(3659) or input(3658) or input(3657) or input(3656) or 
                input(3655) or input(3654) or input(3653) or input(3652) or input(3651) or input(3650) or input(3649) or input(3648);

slice_or(56) <= input(3647) or input(3646) or input(3645) or input(3644) or input(3643) or input(3642) or input(3641) or input(3640) or 
                input(3639) or input(3638) or input(3637) or input(3636) or input(3635) or input(3634) or input(3633) or input(3632) or 
                input(3631) or input(3630) or input(3629) or input(3628) or input(3627) or input(3626) or input(3625) or input(3624) or 
                input(3623) or input(3622) or input(3621) or input(3620) or input(3619) or input(3618) or input(3617) or input(3616) or 
                input(3615) or input(3614) or input(3613) or input(3612) or input(3611) or input(3610) or input(3609) or input(3608) or 
                input(3607) or input(3606) or input(3605) or input(3604) or input(3603) or input(3602) or input(3601) or input(3600) or 
                input(3599) or input(3598) or input(3597) or input(3596) or input(3595) or input(3594) or input(3593) or input(3592) or 
                input(3591) or input(3590) or input(3589) or input(3588) or input(3587) or input(3586) or input(3585) or input(3584);

slice_or(55) <= input(3583) or input(3582) or input(3581) or input(3580) or input(3579) or input(3578) or input(3577) or input(3576) or 
                input(3575) or input(3574) or input(3573) or input(3572) or input(3571) or input(3570) or input(3569) or input(3568) or 
                input(3567) or input(3566) or input(3565) or input(3564) or input(3563) or input(3562) or input(3561) or input(3560) or 
                input(3559) or input(3558) or input(3557) or input(3556) or input(3555) or input(3554) or input(3553) or input(3552) or 
                input(3551) or input(3550) or input(3549) or input(3548) or input(3547) or input(3546) or input(3545) or input(3544) or 
                input(3543) or input(3542) or input(3541) or input(3540) or input(3539) or input(3538) or input(3537) or input(3536) or 
                input(3535) or input(3534) or input(3533) or input(3532) or input(3531) or input(3530) or input(3529) or input(3528) or 
                input(3527) or input(3526) or input(3525) or input(3524) or input(3523) or input(3522) or input(3521) or input(3520);

slice_or(54) <= input(3519) or input(3518) or input(3517) or input(3516) or input(3515) or input(3514) or input(3513) or input(3512) or 
                input(3511) or input(3510) or input(3509) or input(3508) or input(3507) or input(3506) or input(3505) or input(3504) or 
                input(3503) or input(3502) or input(3501) or input(3500) or input(3499) or input(3498) or input(3497) or input(3496) or 
                input(3495) or input(3494) or input(3493) or input(3492) or input(3491) or input(3490) or input(3489) or input(3488) or 
                input(3487) or input(3486) or input(3485) or input(3484) or input(3483) or input(3482) or input(3481) or input(3480) or 
                input(3479) or input(3478) or input(3477) or input(3476) or input(3475) or input(3474) or input(3473) or input(3472) or 
                input(3471) or input(3470) or input(3469) or input(3468) or input(3467) or input(3466) or input(3465) or input(3464) or 
                input(3463) or input(3462) or input(3461) or input(3460) or input(3459) or input(3458) or input(3457) or input(3456);

slice_or(53) <= input(3455) or input(3454) or input(3453) or input(3452) or input(3451) or input(3450) or input(3449) or input(3448) or 
                input(3447) or input(3446) or input(3445) or input(3444) or input(3443) or input(3442) or input(3441) or input(3440) or 
                input(3439) or input(3438) or input(3437) or input(3436) or input(3435) or input(3434) or input(3433) or input(3432) or 
                input(3431) or input(3430) or input(3429) or input(3428) or input(3427) or input(3426) or input(3425) or input(3424) or 
                input(3423) or input(3422) or input(3421) or input(3420) or input(3419) or input(3418) or input(3417) or input(3416) or 
                input(3415) or input(3414) or input(3413) or input(3412) or input(3411) or input(3410) or input(3409) or input(3408) or 
                input(3407) or input(3406) or input(3405) or input(3404) or input(3403) or input(3402) or input(3401) or input(3400) or 
                input(3399) or input(3398) or input(3397) or input(3396) or input(3395) or input(3394) or input(3393) or input(3392);

slice_or(52) <= input(3391) or input(3390) or input(3389) or input(3388) or input(3387) or input(3386) or input(3385) or input(3384) or 
                input(3383) or input(3382) or input(3381) or input(3380) or input(3379) or input(3378) or input(3377) or input(3376) or 
                input(3375) or input(3374) or input(3373) or input(3372) or input(3371) or input(3370) or input(3369) or input(3368) or 
                input(3367) or input(3366) or input(3365) or input(3364) or input(3363) or input(3362) or input(3361) or input(3360) or 
                input(3359) or input(3358) or input(3357) or input(3356) or input(3355) or input(3354) or input(3353) or input(3352) or 
                input(3351) or input(3350) or input(3349) or input(3348) or input(3347) or input(3346) or input(3345) or input(3344) or 
                input(3343) or input(3342) or input(3341) or input(3340) or input(3339) or input(3338) or input(3337) or input(3336) or 
                input(3335) or input(3334) or input(3333) or input(3332) or input(3331) or input(3330) or input(3329) or input(3328);

slice_or(51) <= input(3327) or input(3326) or input(3325) or input(3324) or input(3323) or input(3322) or input(3321) or input(3320) or 
                input(3319) or input(3318) or input(3317) or input(3316) or input(3315) or input(3314) or input(3313) or input(3312) or 
                input(3311) or input(3310) or input(3309) or input(3308) or input(3307) or input(3306) or input(3305) or input(3304) or 
                input(3303) or input(3302) or input(3301) or input(3300) or input(3299) or input(3298) or input(3297) or input(3296) or 
                input(3295) or input(3294) or input(3293) or input(3292) or input(3291) or input(3290) or input(3289) or input(3288) or 
                input(3287) or input(3286) or input(3285) or input(3284) or input(3283) or input(3282) or input(3281) or input(3280) or 
                input(3279) or input(3278) or input(3277) or input(3276) or input(3275) or input(3274) or input(3273) or input(3272) or 
                input(3271) or input(3270) or input(3269) or input(3268) or input(3267) or input(3266) or input(3265) or input(3264);

slice_or(50) <= input(3263) or input(3262) or input(3261) or input(3260) or input(3259) or input(3258) or input(3257) or input(3256) or 
                input(3255) or input(3254) or input(3253) or input(3252) or input(3251) or input(3250) or input(3249) or input(3248) or 
                input(3247) or input(3246) or input(3245) or input(3244) or input(3243) or input(3242) or input(3241) or input(3240) or 
                input(3239) or input(3238) or input(3237) or input(3236) or input(3235) or input(3234) or input(3233) or input(3232) or 
                input(3231) or input(3230) or input(3229) or input(3228) or input(3227) or input(3226) or input(3225) or input(3224) or 
                input(3223) or input(3222) or input(3221) or input(3220) or input(3219) or input(3218) or input(3217) or input(3216) or 
                input(3215) or input(3214) or input(3213) or input(3212) or input(3211) or input(3210) or input(3209) or input(3208) or 
                input(3207) or input(3206) or input(3205) or input(3204) or input(3203) or input(3202) or input(3201) or input(3200);

slice_or(49) <= input(3199) or input(3198) or input(3197) or input(3196) or input(3195) or input(3194) or input(3193) or input(3192) or 
                input(3191) or input(3190) or input(3189) or input(3188) or input(3187) or input(3186) or input(3185) or input(3184) or 
                input(3183) or input(3182) or input(3181) or input(3180) or input(3179) or input(3178) or input(3177) or input(3176) or 
                input(3175) or input(3174) or input(3173) or input(3172) or input(3171) or input(3170) or input(3169) or input(3168) or 
                input(3167) or input(3166) or input(3165) or input(3164) or input(3163) or input(3162) or input(3161) or input(3160) or 
                input(3159) or input(3158) or input(3157) or input(3156) or input(3155) or input(3154) or input(3153) or input(3152) or 
                input(3151) or input(3150) or input(3149) or input(3148) or input(3147) or input(3146) or input(3145) or input(3144) or 
                input(3143) or input(3142) or input(3141) or input(3140) or input(3139) or input(3138) or input(3137) or input(3136);

slice_or(48) <= input(3135) or input(3134) or input(3133) or input(3132) or input(3131) or input(3130) or input(3129) or input(3128) or 
                input(3127) or input(3126) or input(3125) or input(3124) or input(3123) or input(3122) or input(3121) or input(3120) or 
                input(3119) or input(3118) or input(3117) or input(3116) or input(3115) or input(3114) or input(3113) or input(3112) or 
                input(3111) or input(3110) or input(3109) or input(3108) or input(3107) or input(3106) or input(3105) or input(3104) or 
                input(3103) or input(3102) or input(3101) or input(3100) or input(3099) or input(3098) or input(3097) or input(3096) or 
                input(3095) or input(3094) or input(3093) or input(3092) or input(3091) or input(3090) or input(3089) or input(3088) or 
                input(3087) or input(3086) or input(3085) or input(3084) or input(3083) or input(3082) or input(3081) or input(3080) or 
                input(3079) or input(3078) or input(3077) or input(3076) or input(3075) or input(3074) or input(3073) or input(3072);

slice_or(47) <= input(3071) or input(3070) or input(3069) or input(3068) or input(3067) or input(3066) or input(3065) or input(3064) or 
                input(3063) or input(3062) or input(3061) or input(3060) or input(3059) or input(3058) or input(3057) or input(3056) or 
                input(3055) or input(3054) or input(3053) or input(3052) or input(3051) or input(3050) or input(3049) or input(3048) or 
                input(3047) or input(3046) or input(3045) or input(3044) or input(3043) or input(3042) or input(3041) or input(3040) or 
                input(3039) or input(3038) or input(3037) or input(3036) or input(3035) or input(3034) or input(3033) or input(3032) or 
                input(3031) or input(3030) or input(3029) or input(3028) or input(3027) or input(3026) or input(3025) or input(3024) or 
                input(3023) or input(3022) or input(3021) or input(3020) or input(3019) or input(3018) or input(3017) or input(3016) or 
                input(3015) or input(3014) or input(3013) or input(3012) or input(3011) or input(3010) or input(3009) or input(3008);

slice_or(46) <= input(3007) or input(3006) or input(3005) or input(3004) or input(3003) or input(3002) or input(3001) or input(3000) or 
                input(2999) or input(2998) or input(2997) or input(2996) or input(2995) or input(2994) or input(2993) or input(2992) or 
                input(2991) or input(2990) or input(2989) or input(2988) or input(2987) or input(2986) or input(2985) or input(2984) or 
                input(2983) or input(2982) or input(2981) or input(2980) or input(2979) or input(2978) or input(2977) or input(2976) or 
                input(2975) or input(2974) or input(2973) or input(2972) or input(2971) or input(2970) or input(2969) or input(2968) or 
                input(2967) or input(2966) or input(2965) or input(2964) or input(2963) or input(2962) or input(2961) or input(2960) or 
                input(2959) or input(2958) or input(2957) or input(2956) or input(2955) or input(2954) or input(2953) or input(2952) or 
                input(2951) or input(2950) or input(2949) or input(2948) or input(2947) or input(2946) or input(2945) or input(2944);

slice_or(45) <= input(2943) or input(2942) or input(2941) or input(2940) or input(2939) or input(2938) or input(2937) or input(2936) or 
                input(2935) or input(2934) or input(2933) or input(2932) or input(2931) or input(2930) or input(2929) or input(2928) or 
                input(2927) or input(2926) or input(2925) or input(2924) or input(2923) or input(2922) or input(2921) or input(2920) or 
                input(2919) or input(2918) or input(2917) or input(2916) or input(2915) or input(2914) or input(2913) or input(2912) or 
                input(2911) or input(2910) or input(2909) or input(2908) or input(2907) or input(2906) or input(2905) or input(2904) or 
                input(2903) or input(2902) or input(2901) or input(2900) or input(2899) or input(2898) or input(2897) or input(2896) or 
                input(2895) or input(2894) or input(2893) or input(2892) or input(2891) or input(2890) or input(2889) or input(2888) or 
                input(2887) or input(2886) or input(2885) or input(2884) or input(2883) or input(2882) or input(2881) or input(2880);

slice_or(44) <= input(2879) or input(2878) or input(2877) or input(2876) or input(2875) or input(2874) or input(2873) or input(2872) or 
                input(2871) or input(2870) or input(2869) or input(2868) or input(2867) or input(2866) or input(2865) or input(2864) or 
                input(2863) or input(2862) or input(2861) or input(2860) or input(2859) or input(2858) or input(2857) or input(2856) or 
                input(2855) or input(2854) or input(2853) or input(2852) or input(2851) or input(2850) or input(2849) or input(2848) or 
                input(2847) or input(2846) or input(2845) or input(2844) or input(2843) or input(2842) or input(2841) or input(2840) or 
                input(2839) or input(2838) or input(2837) or input(2836) or input(2835) or input(2834) or input(2833) or input(2832) or 
                input(2831) or input(2830) or input(2829) or input(2828) or input(2827) or input(2826) or input(2825) or input(2824) or 
                input(2823) or input(2822) or input(2821) or input(2820) or input(2819) or input(2818) or input(2817) or input(2816);

slice_or(43) <= input(2815) or input(2814) or input(2813) or input(2812) or input(2811) or input(2810) or input(2809) or input(2808) or 
                input(2807) or input(2806) or input(2805) or input(2804) or input(2803) or input(2802) or input(2801) or input(2800) or 
                input(2799) or input(2798) or input(2797) or input(2796) or input(2795) or input(2794) or input(2793) or input(2792) or 
                input(2791) or input(2790) or input(2789) or input(2788) or input(2787) or input(2786) or input(2785) or input(2784) or 
                input(2783) or input(2782) or input(2781) or input(2780) or input(2779) or input(2778) or input(2777) or input(2776) or 
                input(2775) or input(2774) or input(2773) or input(2772) or input(2771) or input(2770) or input(2769) or input(2768) or 
                input(2767) or input(2766) or input(2765) or input(2764) or input(2763) or input(2762) or input(2761) or input(2760) or 
                input(2759) or input(2758) or input(2757) or input(2756) or input(2755) or input(2754) or input(2753) or input(2752);

slice_or(42) <= input(2751) or input(2750) or input(2749) or input(2748) or input(2747) or input(2746) or input(2745) or input(2744) or 
                input(2743) or input(2742) or input(2741) or input(2740) or input(2739) or input(2738) or input(2737) or input(2736) or 
                input(2735) or input(2734) or input(2733) or input(2732) or input(2731) or input(2730) or input(2729) or input(2728) or 
                input(2727) or input(2726) or input(2725) or input(2724) or input(2723) or input(2722) or input(2721) or input(2720) or 
                input(2719) or input(2718) or input(2717) or input(2716) or input(2715) or input(2714) or input(2713) or input(2712) or 
                input(2711) or input(2710) or input(2709) or input(2708) or input(2707) or input(2706) or input(2705) or input(2704) or 
                input(2703) or input(2702) or input(2701) or input(2700) or input(2699) or input(2698) or input(2697) or input(2696) or 
                input(2695) or input(2694) or input(2693) or input(2692) or input(2691) or input(2690) or input(2689) or input(2688);

slice_or(41) <= input(2687) or input(2686) or input(2685) or input(2684) or input(2683) or input(2682) or input(2681) or input(2680) or 
                input(2679) or input(2678) or input(2677) or input(2676) or input(2675) or input(2674) or input(2673) or input(2672) or 
                input(2671) or input(2670) or input(2669) or input(2668) or input(2667) or input(2666) or input(2665) or input(2664) or 
                input(2663) or input(2662) or input(2661) or input(2660) or input(2659) or input(2658) or input(2657) or input(2656) or 
                input(2655) or input(2654) or input(2653) or input(2652) or input(2651) or input(2650) or input(2649) or input(2648) or 
                input(2647) or input(2646) or input(2645) or input(2644) or input(2643) or input(2642) or input(2641) or input(2640) or 
                input(2639) or input(2638) or input(2637) or input(2636) or input(2635) or input(2634) or input(2633) or input(2632) or 
                input(2631) or input(2630) or input(2629) or input(2628) or input(2627) or input(2626) or input(2625) or input(2624);

slice_or(40) <= input(2623) or input(2622) or input(2621) or input(2620) or input(2619) or input(2618) or input(2617) or input(2616) or 
                input(2615) or input(2614) or input(2613) or input(2612) or input(2611) or input(2610) or input(2609) or input(2608) or 
                input(2607) or input(2606) or input(2605) or input(2604) or input(2603) or input(2602) or input(2601) or input(2600) or 
                input(2599) or input(2598) or input(2597) or input(2596) or input(2595) or input(2594) or input(2593) or input(2592) or 
                input(2591) or input(2590) or input(2589) or input(2588) or input(2587) or input(2586) or input(2585) or input(2584) or 
                input(2583) or input(2582) or input(2581) or input(2580) or input(2579) or input(2578) or input(2577) or input(2576) or 
                input(2575) or input(2574) or input(2573) or input(2572) or input(2571) or input(2570) or input(2569) or input(2568) or 
                input(2567) or input(2566) or input(2565) or input(2564) or input(2563) or input(2562) or input(2561) or input(2560);

slice_or(39) <= input(2559) or input(2558) or input(2557) or input(2556) or input(2555) or input(2554) or input(2553) or input(2552) or 
                input(2551) or input(2550) or input(2549) or input(2548) or input(2547) or input(2546) or input(2545) or input(2544) or 
                input(2543) or input(2542) or input(2541) or input(2540) or input(2539) or input(2538) or input(2537) or input(2536) or 
                input(2535) or input(2534) or input(2533) or input(2532) or input(2531) or input(2530) or input(2529) or input(2528) or 
                input(2527) or input(2526) or input(2525) or input(2524) or input(2523) or input(2522) or input(2521) or input(2520) or 
                input(2519) or input(2518) or input(2517) or input(2516) or input(2515) or input(2514) or input(2513) or input(2512) or 
                input(2511) or input(2510) or input(2509) or input(2508) or input(2507) or input(2506) or input(2505) or input(2504) or 
                input(2503) or input(2502) or input(2501) or input(2500) or input(2499) or input(2498) or input(2497) or input(2496);

slice_or(38) <= input(2495) or input(2494) or input(2493) or input(2492) or input(2491) or input(2490) or input(2489) or input(2488) or 
                input(2487) or input(2486) or input(2485) or input(2484) or input(2483) or input(2482) or input(2481) or input(2480) or 
                input(2479) or input(2478) or input(2477) or input(2476) or input(2475) or input(2474) or input(2473) or input(2472) or 
                input(2471) or input(2470) or input(2469) or input(2468) or input(2467) or input(2466) or input(2465) or input(2464) or 
                input(2463) or input(2462) or input(2461) or input(2460) or input(2459) or input(2458) or input(2457) or input(2456) or 
                input(2455) or input(2454) or input(2453) or input(2452) or input(2451) or input(2450) or input(2449) or input(2448) or 
                input(2447) or input(2446) or input(2445) or input(2444) or input(2443) or input(2442) or input(2441) or input(2440) or 
                input(2439) or input(2438) or input(2437) or input(2436) or input(2435) or input(2434) or input(2433) or input(2432);

slice_or(37) <= input(2431) or input(2430) or input(2429) or input(2428) or input(2427) or input(2426) or input(2425) or input(2424) or 
                input(2423) or input(2422) or input(2421) or input(2420) or input(2419) or input(2418) or input(2417) or input(2416) or 
                input(2415) or input(2414) or input(2413) or input(2412) or input(2411) or input(2410) or input(2409) or input(2408) or 
                input(2407) or input(2406) or input(2405) or input(2404) or input(2403) or input(2402) or input(2401) or input(2400) or 
                input(2399) or input(2398) or input(2397) or input(2396) or input(2395) or input(2394) or input(2393) or input(2392) or 
                input(2391) or input(2390) or input(2389) or input(2388) or input(2387) or input(2386) or input(2385) or input(2384) or 
                input(2383) or input(2382) or input(2381) or input(2380) or input(2379) or input(2378) or input(2377) or input(2376) or 
                input(2375) or input(2374) or input(2373) or input(2372) or input(2371) or input(2370) or input(2369) or input(2368);

slice_or(36) <= input(2367) or input(2366) or input(2365) or input(2364) or input(2363) or input(2362) or input(2361) or input(2360) or 
                input(2359) or input(2358) or input(2357) or input(2356) or input(2355) or input(2354) or input(2353) or input(2352) or 
                input(2351) or input(2350) or input(2349) or input(2348) or input(2347) or input(2346) or input(2345) or input(2344) or 
                input(2343) or input(2342) or input(2341) or input(2340) or input(2339) or input(2338) or input(2337) or input(2336) or 
                input(2335) or input(2334) or input(2333) or input(2332) or input(2331) or input(2330) or input(2329) or input(2328) or 
                input(2327) or input(2326) or input(2325) or input(2324) or input(2323) or input(2322) or input(2321) or input(2320) or 
                input(2319) or input(2318) or input(2317) or input(2316) or input(2315) or input(2314) or input(2313) or input(2312) or 
                input(2311) or input(2310) or input(2309) or input(2308) or input(2307) or input(2306) or input(2305) or input(2304);

slice_or(35) <= input(2303) or input(2302) or input(2301) or input(2300) or input(2299) or input(2298) or input(2297) or input(2296) or 
                input(2295) or input(2294) or input(2293) or input(2292) or input(2291) or input(2290) or input(2289) or input(2288) or 
                input(2287) or input(2286) or input(2285) or input(2284) or input(2283) or input(2282) or input(2281) or input(2280) or 
                input(2279) or input(2278) or input(2277) or input(2276) or input(2275) or input(2274) or input(2273) or input(2272) or 
                input(2271) or input(2270) or input(2269) or input(2268) or input(2267) or input(2266) or input(2265) or input(2264) or 
                input(2263) or input(2262) or input(2261) or input(2260) or input(2259) or input(2258) or input(2257) or input(2256) or 
                input(2255) or input(2254) or input(2253) or input(2252) or input(2251) or input(2250) or input(2249) or input(2248) or 
                input(2247) or input(2246) or input(2245) or input(2244) or input(2243) or input(2242) or input(2241) or input(2240);

slice_or(34) <= input(2239) or input(2238) or input(2237) or input(2236) or input(2235) or input(2234) or input(2233) or input(2232) or 
                input(2231) or input(2230) or input(2229) or input(2228) or input(2227) or input(2226) or input(2225) or input(2224) or 
                input(2223) or input(2222) or input(2221) or input(2220) or input(2219) or input(2218) or input(2217) or input(2216) or 
                input(2215) or input(2214) or input(2213) or input(2212) or input(2211) or input(2210) or input(2209) or input(2208) or 
                input(2207) or input(2206) or input(2205) or input(2204) or input(2203) or input(2202) or input(2201) or input(2200) or 
                input(2199) or input(2198) or input(2197) or input(2196) or input(2195) or input(2194) or input(2193) or input(2192) or 
                input(2191) or input(2190) or input(2189) or input(2188) or input(2187) or input(2186) or input(2185) or input(2184) or 
                input(2183) or input(2182) or input(2181) or input(2180) or input(2179) or input(2178) or input(2177) or input(2176);

slice_or(33) <= input(2175) or input(2174) or input(2173) or input(2172) or input(2171) or input(2170) or input(2169) or input(2168) or 
                input(2167) or input(2166) or input(2165) or input(2164) or input(2163) or input(2162) or input(2161) or input(2160) or 
                input(2159) or input(2158) or input(2157) or input(2156) or input(2155) or input(2154) or input(2153) or input(2152) or 
                input(2151) or input(2150) or input(2149) or input(2148) or input(2147) or input(2146) or input(2145) or input(2144) or 
                input(2143) or input(2142) or input(2141) or input(2140) or input(2139) or input(2138) or input(2137) or input(2136) or 
                input(2135) or input(2134) or input(2133) or input(2132) or input(2131) or input(2130) or input(2129) or input(2128) or 
                input(2127) or input(2126) or input(2125) or input(2124) or input(2123) or input(2122) or input(2121) or input(2120) or 
                input(2119) or input(2118) or input(2117) or input(2116) or input(2115) or input(2114) or input(2113) or input(2112);

slice_or(32) <= input(2111) or input(2110) or input(2109) or input(2108) or input(2107) or input(2106) or input(2105) or input(2104) or 
                input(2103) or input(2102) or input(2101) or input(2100) or input(2099) or input(2098) or input(2097) or input(2096) or 
                input(2095) or input(2094) or input(2093) or input(2092) or input(2091) or input(2090) or input(2089) or input(2088) or 
                input(2087) or input(2086) or input(2085) or input(2084) or input(2083) or input(2082) or input(2081) or input(2080) or 
                input(2079) or input(2078) or input(2077) or input(2076) or input(2075) or input(2074) or input(2073) or input(2072) or 
                input(2071) or input(2070) or input(2069) or input(2068) or input(2067) or input(2066) or input(2065) or input(2064) or 
                input(2063) or input(2062) or input(2061) or input(2060) or input(2059) or input(2058) or input(2057) or input(2056) or 
                input(2055) or input(2054) or input(2053) or input(2052) or input(2051) or input(2050) or input(2049) or input(2048);

slice_or(31) <= input(2047) or input(2046) or input(2045) or input(2044) or input(2043) or input(2042) or input(2041) or input(2040) or 
                input(2039) or input(2038) or input(2037) or input(2036) or input(2035) or input(2034) or input(2033) or input(2032) or 
                input(2031) or input(2030) or input(2029) or input(2028) or input(2027) or input(2026) or input(2025) or input(2024) or 
                input(2023) or input(2022) or input(2021) or input(2020) or input(2019) or input(2018) or input(2017) or input(2016) or 
                input(2015) or input(2014) or input(2013) or input(2012) or input(2011) or input(2010) or input(2009) or input(2008) or 
                input(2007) or input(2006) or input(2005) or input(2004) or input(2003) or input(2002) or input(2001) or input(2000) or 
                input(1999) or input(1998) or input(1997) or input(1996) or input(1995) or input(1994) or input(1993) or input(1992) or 
                input(1991) or input(1990) or input(1989) or input(1988) or input(1987) or input(1986) or input(1985) or input(1984);

slice_or(30) <= input(1983) or input(1982) or input(1981) or input(1980) or input(1979) or input(1978) or input(1977) or input(1976) or 
                input(1975) or input(1974) or input(1973) or input(1972) or input(1971) or input(1970) or input(1969) or input(1968) or 
                input(1967) or input(1966) or input(1965) or input(1964) or input(1963) or input(1962) or input(1961) or input(1960) or 
                input(1959) or input(1958) or input(1957) or input(1956) or input(1955) or input(1954) or input(1953) or input(1952) or 
                input(1951) or input(1950) or input(1949) or input(1948) or input(1947) or input(1946) or input(1945) or input(1944) or 
                input(1943) or input(1942) or input(1941) or input(1940) or input(1939) or input(1938) or input(1937) or input(1936) or 
                input(1935) or input(1934) or input(1933) or input(1932) or input(1931) or input(1930) or input(1929) or input(1928) or 
                input(1927) or input(1926) or input(1925) or input(1924) or input(1923) or input(1922) or input(1921) or input(1920);

slice_or(29) <= input(1919) or input(1918) or input(1917) or input(1916) or input(1915) or input(1914) or input(1913) or input(1912) or 
                input(1911) or input(1910) or input(1909) or input(1908) or input(1907) or input(1906) or input(1905) or input(1904) or 
                input(1903) or input(1902) or input(1901) or input(1900) or input(1899) or input(1898) or input(1897) or input(1896) or 
                input(1895) or input(1894) or input(1893) or input(1892) or input(1891) or input(1890) or input(1889) or input(1888) or 
                input(1887) or input(1886) or input(1885) or input(1884) or input(1883) or input(1882) or input(1881) or input(1880) or 
                input(1879) or input(1878) or input(1877) or input(1876) or input(1875) or input(1874) or input(1873) or input(1872) or 
                input(1871) or input(1870) or input(1869) or input(1868) or input(1867) or input(1866) or input(1865) or input(1864) or 
                input(1863) or input(1862) or input(1861) or input(1860) or input(1859) or input(1858) or input(1857) or input(1856);

slice_or(28) <= input(1855) or input(1854) or input(1853) or input(1852) or input(1851) or input(1850) or input(1849) or input(1848) or 
                input(1847) or input(1846) or input(1845) or input(1844) or input(1843) or input(1842) or input(1841) or input(1840) or 
                input(1839) or input(1838) or input(1837) or input(1836) or input(1835) or input(1834) or input(1833) or input(1832) or 
                input(1831) or input(1830) or input(1829) or input(1828) or input(1827) or input(1826) or input(1825) or input(1824) or 
                input(1823) or input(1822) or input(1821) or input(1820) or input(1819) or input(1818) or input(1817) or input(1816) or 
                input(1815) or input(1814) or input(1813) or input(1812) or input(1811) or input(1810) or input(1809) or input(1808) or 
                input(1807) or input(1806) or input(1805) or input(1804) or input(1803) or input(1802) or input(1801) or input(1800) or 
                input(1799) or input(1798) or input(1797) or input(1796) or input(1795) or input(1794) or input(1793) or input(1792);

slice_or(27) <= input(1791) or input(1790) or input(1789) or input(1788) or input(1787) or input(1786) or input(1785) or input(1784) or 
                input(1783) or input(1782) or input(1781) or input(1780) or input(1779) or input(1778) or input(1777) or input(1776) or 
                input(1775) or input(1774) or input(1773) or input(1772) or input(1771) or input(1770) or input(1769) or input(1768) or 
                input(1767) or input(1766) or input(1765) or input(1764) or input(1763) or input(1762) or input(1761) or input(1760) or 
                input(1759) or input(1758) or input(1757) or input(1756) or input(1755) or input(1754) or input(1753) or input(1752) or 
                input(1751) or input(1750) or input(1749) or input(1748) or input(1747) or input(1746) or input(1745) or input(1744) or 
                input(1743) or input(1742) or input(1741) or input(1740) or input(1739) or input(1738) or input(1737) or input(1736) or 
                input(1735) or input(1734) or input(1733) or input(1732) or input(1731) or input(1730) or input(1729) or input(1728);

slice_or(26) <= input(1727) or input(1726) or input(1725) or input(1724) or input(1723) or input(1722) or input(1721) or input(1720) or 
                input(1719) or input(1718) or input(1717) or input(1716) or input(1715) or input(1714) or input(1713) or input(1712) or 
                input(1711) or input(1710) or input(1709) or input(1708) or input(1707) or input(1706) or input(1705) or input(1704) or 
                input(1703) or input(1702) or input(1701) or input(1700) or input(1699) or input(1698) or input(1697) or input(1696) or 
                input(1695) or input(1694) or input(1693) or input(1692) or input(1691) or input(1690) or input(1689) or input(1688) or 
                input(1687) or input(1686) or input(1685) or input(1684) or input(1683) or input(1682) or input(1681) or input(1680) or 
                input(1679) or input(1678) or input(1677) or input(1676) or input(1675) or input(1674) or input(1673) or input(1672) or 
                input(1671) or input(1670) or input(1669) or input(1668) or input(1667) or input(1666) or input(1665) or input(1664);

slice_or(25) <= input(1663) or input(1662) or input(1661) or input(1660) or input(1659) or input(1658) or input(1657) or input(1656) or 
                input(1655) or input(1654) or input(1653) or input(1652) or input(1651) or input(1650) or input(1649) or input(1648) or 
                input(1647) or input(1646) or input(1645) or input(1644) or input(1643) or input(1642) or input(1641) or input(1640) or 
                input(1639) or input(1638) or input(1637) or input(1636) or input(1635) or input(1634) or input(1633) or input(1632) or 
                input(1631) or input(1630) or input(1629) or input(1628) or input(1627) or input(1626) or input(1625) or input(1624) or 
                input(1623) or input(1622) or input(1621) or input(1620) or input(1619) or input(1618) or input(1617) or input(1616) or 
                input(1615) or input(1614) or input(1613) or input(1612) or input(1611) or input(1610) or input(1609) or input(1608) or 
                input(1607) or input(1606) or input(1605) or input(1604) or input(1603) or input(1602) or input(1601) or input(1600);

slice_or(24) <= input(1599) or input(1598) or input(1597) or input(1596) or input(1595) or input(1594) or input(1593) or input(1592) or 
                input(1591) or input(1590) or input(1589) or input(1588) or input(1587) or input(1586) or input(1585) or input(1584) or 
                input(1583) or input(1582) or input(1581) or input(1580) or input(1579) or input(1578) or input(1577) or input(1576) or 
                input(1575) or input(1574) or input(1573) or input(1572) or input(1571) or input(1570) or input(1569) or input(1568) or 
                input(1567) or input(1566) or input(1565) or input(1564) or input(1563) or input(1562) or input(1561) or input(1560) or 
                input(1559) or input(1558) or input(1557) or input(1556) or input(1555) or input(1554) or input(1553) or input(1552) or 
                input(1551) or input(1550) or input(1549) or input(1548) or input(1547) or input(1546) or input(1545) or input(1544) or 
                input(1543) or input(1542) or input(1541) or input(1540) or input(1539) or input(1538) or input(1537) or input(1536);

slice_or(23) <= input(1535) or input(1534) or input(1533) or input(1532) or input(1531) or input(1530) or input(1529) or input(1528) or 
                input(1527) or input(1526) or input(1525) or input(1524) or input(1523) or input(1522) or input(1521) or input(1520) or 
                input(1519) or input(1518) or input(1517) or input(1516) or input(1515) or input(1514) or input(1513) or input(1512) or 
                input(1511) or input(1510) or input(1509) or input(1508) or input(1507) or input(1506) or input(1505) or input(1504) or 
                input(1503) or input(1502) or input(1501) or input(1500) or input(1499) or input(1498) or input(1497) or input(1496) or 
                input(1495) or input(1494) or input(1493) or input(1492) or input(1491) or input(1490) or input(1489) or input(1488) or 
                input(1487) or input(1486) or input(1485) or input(1484) or input(1483) or input(1482) or input(1481) or input(1480) or 
                input(1479) or input(1478) or input(1477) or input(1476) or input(1475) or input(1474) or input(1473) or input(1472);

slice_or(22) <= input(1471) or input(1470) or input(1469) or input(1468) or input(1467) or input(1466) or input(1465) or input(1464) or 
                input(1463) or input(1462) or input(1461) or input(1460) or input(1459) or input(1458) or input(1457) or input(1456) or 
                input(1455) or input(1454) or input(1453) or input(1452) or input(1451) or input(1450) or input(1449) or input(1448) or 
                input(1447) or input(1446) or input(1445) or input(1444) or input(1443) or input(1442) or input(1441) or input(1440) or 
                input(1439) or input(1438) or input(1437) or input(1436) or input(1435) or input(1434) or input(1433) or input(1432) or 
                input(1431) or input(1430) or input(1429) or input(1428) or input(1427) or input(1426) or input(1425) or input(1424) or 
                input(1423) or input(1422) or input(1421) or input(1420) or input(1419) or input(1418) or input(1417) or input(1416) or 
                input(1415) or input(1414) or input(1413) or input(1412) or input(1411) or input(1410) or input(1409) or input(1408);

slice_or(21) <= input(1407) or input(1406) or input(1405) or input(1404) or input(1403) or input(1402) or input(1401) or input(1400) or 
                input(1399) or input(1398) or input(1397) or input(1396) or input(1395) or input(1394) or input(1393) or input(1392) or 
                input(1391) or input(1390) or input(1389) or input(1388) or input(1387) or input(1386) or input(1385) or input(1384) or 
                input(1383) or input(1382) or input(1381) or input(1380) or input(1379) or input(1378) or input(1377) or input(1376) or 
                input(1375) or input(1374) or input(1373) or input(1372) or input(1371) or input(1370) or input(1369) or input(1368) or 
                input(1367) or input(1366) or input(1365) or input(1364) or input(1363) or input(1362) or input(1361) or input(1360) or 
                input(1359) or input(1358) or input(1357) or input(1356) or input(1355) or input(1354) or input(1353) or input(1352) or 
                input(1351) or input(1350) or input(1349) or input(1348) or input(1347) or input(1346) or input(1345) or input(1344);

slice_or(20) <= input(1343) or input(1342) or input(1341) or input(1340) or input(1339) or input(1338) or input(1337) or input(1336) or 
                input(1335) or input(1334) or input(1333) or input(1332) or input(1331) or input(1330) or input(1329) or input(1328) or 
                input(1327) or input(1326) or input(1325) or input(1324) or input(1323) or input(1322) or input(1321) or input(1320) or 
                input(1319) or input(1318) or input(1317) or input(1316) or input(1315) or input(1314) or input(1313) or input(1312) or 
                input(1311) or input(1310) or input(1309) or input(1308) or input(1307) or input(1306) or input(1305) or input(1304) or 
                input(1303) or input(1302) or input(1301) or input(1300) or input(1299) or input(1298) or input(1297) or input(1296) or 
                input(1295) or input(1294) or input(1293) or input(1292) or input(1291) or input(1290) or input(1289) or input(1288) or 
                input(1287) or input(1286) or input(1285) or input(1284) or input(1283) or input(1282) or input(1281) or input(1280);

slice_or(19) <= input(1279) or input(1278) or input(1277) or input(1276) or input(1275) or input(1274) or input(1273) or input(1272) or 
                input(1271) or input(1270) or input(1269) or input(1268) or input(1267) or input(1266) or input(1265) or input(1264) or 
                input(1263) or input(1262) or input(1261) or input(1260) or input(1259) or input(1258) or input(1257) or input(1256) or 
                input(1255) or input(1254) or input(1253) or input(1252) or input(1251) or input(1250) or input(1249) or input(1248) or 
                input(1247) or input(1246) or input(1245) or input(1244) or input(1243) or input(1242) or input(1241) or input(1240) or 
                input(1239) or input(1238) or input(1237) or input(1236) or input(1235) or input(1234) or input(1233) or input(1232) or 
                input(1231) or input(1230) or input(1229) or input(1228) or input(1227) or input(1226) or input(1225) or input(1224) or 
                input(1223) or input(1222) or input(1221) or input(1220) or input(1219) or input(1218) or input(1217) or input(1216);

slice_or(18) <= input(1215) or input(1214) or input(1213) or input(1212) or input(1211) or input(1210) or input(1209) or input(1208) or 
                input(1207) or input(1206) or input(1205) or input(1204) or input(1203) or input(1202) or input(1201) or input(1200) or 
                input(1199) or input(1198) or input(1197) or input(1196) or input(1195) or input(1194) or input(1193) or input(1192) or 
                input(1191) or input(1190) or input(1189) or input(1188) or input(1187) or input(1186) or input(1185) or input(1184) or 
                input(1183) or input(1182) or input(1181) or input(1180) or input(1179) or input(1178) or input(1177) or input(1176) or 
                input(1175) or input(1174) or input(1173) or input(1172) or input(1171) or input(1170) or input(1169) or input(1168) or 
                input(1167) or input(1166) or input(1165) or input(1164) or input(1163) or input(1162) or input(1161) or input(1160) or 
                input(1159) or input(1158) or input(1157) or input(1156) or input(1155) or input(1154) or input(1153) or input(1152);

slice_or(17) <= input(1151) or input(1150) or input(1149) or input(1148) or input(1147) or input(1146) or input(1145) or input(1144) or 
                input(1143) or input(1142) or input(1141) or input(1140) or input(1139) or input(1138) or input(1137) or input(1136) or 
                input(1135) or input(1134) or input(1133) or input(1132) or input(1131) or input(1130) or input(1129) or input(1128) or 
                input(1127) or input(1126) or input(1125) or input(1124) or input(1123) or input(1122) or input(1121) or input(1120) or 
                input(1119) or input(1118) or input(1117) or input(1116) or input(1115) or input(1114) or input(1113) or input(1112) or 
                input(1111) or input(1110) or input(1109) or input(1108) or input(1107) or input(1106) or input(1105) or input(1104) or 
                input(1103) or input(1102) or input(1101) or input(1100) or input(1099) or input(1098) or input(1097) or input(1096) or 
                input(1095) or input(1094) or input(1093) or input(1092) or input(1091) or input(1090) or input(1089) or input(1088);

slice_or(16) <= input(1087) or input(1086) or input(1085) or input(1084) or input(1083) or input(1082) or input(1081) or input(1080) or 
                input(1079) or input(1078) or input(1077) or input(1076) or input(1075) or input(1074) or input(1073) or input(1072) or 
                input(1071) or input(1070) or input(1069) or input(1068) or input(1067) or input(1066) or input(1065) or input(1064) or 
                input(1063) or input(1062) or input(1061) or input(1060) or input(1059) or input(1058) or input(1057) or input(1056) or 
                input(1055) or input(1054) or input(1053) or input(1052) or input(1051) or input(1050) or input(1049) or input(1048) or 
                input(1047) or input(1046) or input(1045) or input(1044) or input(1043) or input(1042) or input(1041) or input(1040) or 
                input(1039) or input(1038) or input(1037) or input(1036) or input(1035) or input(1034) or input(1033) or input(1032) or 
                input(1031) or input(1030) or input(1029) or input(1028) or input(1027) or input(1026) or input(1025) or input(1024);

slice_or(15) <= input(1023) or input(1022) or input(1021) or input(1020) or input(1019) or input(1018) or input(1017) or input(1016) or 
                input(1015) or input(1014) or input(1013) or input(1012) or input(1011) or input(1010) or input(1009) or input(1008) or 
                input(1007) or input(1006) or input(1005) or input(1004) or input(1003) or input(1002) or input(1001) or input(1000) or 
                input(999) or input(998) or input(997) or input(996) or input(995) or input(994) or input(993) or input(992) or 
                input(991) or input(990) or input(989) or input(988) or input(987) or input(986) or input(985) or input(984) or 
                input(983) or input(982) or input(981) or input(980) or input(979) or input(978) or input(977) or input(976) or 
                input(975) or input(974) or input(973) or input(972) or input(971) or input(970) or input(969) or input(968) or 
                input(967) or input(966) or input(965) or input(964) or input(963) or input(962) or input(961) or input(960);

slice_or(14) <= input(959) or input(958) or input(957) or input(956) or input(955) or input(954) or input(953) or input(952) or 
                input(951) or input(950) or input(949) or input(948) or input(947) or input(946) or input(945) or input(944) or 
                input(943) or input(942) or input(941) or input(940) or input(939) or input(938) or input(937) or input(936) or 
                input(935) or input(934) or input(933) or input(932) or input(931) or input(930) or input(929) or input(928) or 
                input(927) or input(926) or input(925) or input(924) or input(923) or input(922) or input(921) or input(920) or 
                input(919) or input(918) or input(917) or input(916) or input(915) or input(914) or input(913) or input(912) or 
                input(911) or input(910) or input(909) or input(908) or input(907) or input(906) or input(905) or input(904) or 
                input(903) or input(902) or input(901) or input(900) or input(899) or input(898) or input(897) or input(896);

slice_or(13) <= input(895) or input(894) or input(893) or input(892) or input(891) or input(890) or input(889) or input(888) or 
                input(887) or input(886) or input(885) or input(884) or input(883) or input(882) or input(881) or input(880) or 
                input(879) or input(878) or input(877) or input(876) or input(875) or input(874) or input(873) or input(872) or 
                input(871) or input(870) or input(869) or input(868) or input(867) or input(866) or input(865) or input(864) or 
                input(863) or input(862) or input(861) or input(860) or input(859) or input(858) or input(857) or input(856) or 
                input(855) or input(854) or input(853) or input(852) or input(851) or input(850) or input(849) or input(848) or 
                input(847) or input(846) or input(845) or input(844) or input(843) or input(842) or input(841) or input(840) or 
                input(839) or input(838) or input(837) or input(836) or input(835) or input(834) or input(833) or input(832);

slice_or(12) <= input(831) or input(830) or input(829) or input(828) or input(827) or input(826) or input(825) or input(824) or 
                input(823) or input(822) or input(821) or input(820) or input(819) or input(818) or input(817) or input(816) or 
                input(815) or input(814) or input(813) or input(812) or input(811) or input(810) or input(809) or input(808) or 
                input(807) or input(806) or input(805) or input(804) or input(803) or input(802) or input(801) or input(800) or 
                input(799) or input(798) or input(797) or input(796) or input(795) or input(794) or input(793) or input(792) or 
                input(791) or input(790) or input(789) or input(788) or input(787) or input(786) or input(785) or input(784) or 
                input(783) or input(782) or input(781) or input(780) or input(779) or input(778) or input(777) or input(776) or 
                input(775) or input(774) or input(773) or input(772) or input(771) or input(770) or input(769) or input(768);

slice_or(11) <= input(767) or input(766) or input(765) or input(764) or input(763) or input(762) or input(761) or input(760) or 
                input(759) or input(758) or input(757) or input(756) or input(755) or input(754) or input(753) or input(752) or 
                input(751) or input(750) or input(749) or input(748) or input(747) or input(746) or input(745) or input(744) or 
                input(743) or input(742) or input(741) or input(740) or input(739) or input(738) or input(737) or input(736) or 
                input(735) or input(734) or input(733) or input(732) or input(731) or input(730) or input(729) or input(728) or 
                input(727) or input(726) or input(725) or input(724) or input(723) or input(722) or input(721) or input(720) or 
                input(719) or input(718) or input(717) or input(716) or input(715) or input(714) or input(713) or input(712) or 
                input(711) or input(710) or input(709) or input(708) or input(707) or input(706) or input(705) or input(704);

slice_or(10) <= input(703) or input(702) or input(701) or input(700) or input(699) or input(698) or input(697) or input(696) or 
                input(695) or input(694) or input(693) or input(692) or input(691) or input(690) or input(689) or input(688) or 
                input(687) or input(686) or input(685) or input(684) or input(683) or input(682) or input(681) or input(680) or 
                input(679) or input(678) or input(677) or input(676) or input(675) or input(674) or input(673) or input(672) or 
                input(671) or input(670) or input(669) or input(668) or input(667) or input(666) or input(665) or input(664) or 
                input(663) or input(662) or input(661) or input(660) or input(659) or input(658) or input(657) or input(656) or 
                input(655) or input(654) or input(653) or input(652) or input(651) or input(650) or input(649) or input(648) or 
                input(647) or input(646) or input(645) or input(644) or input(643) or input(642) or input(641) or input(640);

slice_or(9)  <= input(639) or input(638) or input(637) or input(636) or input(635) or input(634) or input(633) or input(632) or 
                input(631) or input(630) or input(629) or input(628) or input(627) or input(626) or input(625) or input(624) or 
                input(623) or input(622) or input(621) or input(620) or input(619) or input(618) or input(617) or input(616) or 
                input(615) or input(614) or input(613) or input(612) or input(611) or input(610) or input(609) or input(608) or 
                input(607) or input(606) or input(605) or input(604) or input(603) or input(602) or input(601) or input(600) or 
                input(599) or input(598) or input(597) or input(596) or input(595) or input(594) or input(593) or input(592) or 
                input(591) or input(590) or input(589) or input(588) or input(587) or input(586) or input(585) or input(584) or 
                input(583) or input(582) or input(581) or input(580) or input(579) or input(578) or input(577) or input(576);

slice_or(8)  <= input(575) or input(574) or input(573) or input(572) or input(571) or input(570) or input(569) or input(568) or 
                input(567) or input(566) or input(565) or input(564) or input(563) or input(562) or input(561) or input(560) or 
                input(559) or input(558) or input(557) or input(556) or input(555) or input(554) or input(553) or input(552) or 
                input(551) or input(550) or input(549) or input(548) or input(547) or input(546) or input(545) or input(544) or 
                input(543) or input(542) or input(541) or input(540) or input(539) or input(538) or input(537) or input(536) or 
                input(535) or input(534) or input(533) or input(532) or input(531) or input(530) or input(529) or input(528) or 
                input(527) or input(526) or input(525) or input(524) or input(523) or input(522) or input(521) or input(520) or 
                input(519) or input(518) or input(517) or input(516) or input(515) or input(514) or input(513) or input(512);

slice_or(7)  <= input(511) or input(510) or input(509) or input(508) or input(507) or input(506) or input(505) or input(504) or 
                input(503) or input(502) or input(501) or input(500) or input(499) or input(498) or input(497) or input(496) or 
                input(495) or input(494) or input(493) or input(492) or input(491) or input(490) or input(489) or input(488) or 
                input(487) or input(486) or input(485) or input(484) or input(483) or input(482) or input(481) or input(480) or 
                input(479) or input(478) or input(477) or input(476) or input(475) or input(474) or input(473) or input(472) or 
                input(471) or input(470) or input(469) or input(468) or input(467) or input(466) or input(465) or input(464) or 
                input(463) or input(462) or input(461) or input(460) or input(459) or input(458) or input(457) or input(456) or 
                input(455) or input(454) or input(453) or input(452) or input(451) or input(450) or input(449) or input(448);

slice_or(6)  <= input(447) or input(446) or input(445) or input(444) or input(443) or input(442) or input(441) or input(440) or 
                input(439) or input(438) or input(437) or input(436) or input(435) or input(434) or input(433) or input(432) or 
                input(431) or input(430) or input(429) or input(428) or input(427) or input(426) or input(425) or input(424) or 
                input(423) or input(422) or input(421) or input(420) or input(419) or input(418) or input(417) or input(416) or 
                input(415) or input(414) or input(413) or input(412) or input(411) or input(410) or input(409) or input(408) or 
                input(407) or input(406) or input(405) or input(404) or input(403) or input(402) or input(401) or input(400) or 
                input(399) or input(398) or input(397) or input(396) or input(395) or input(394) or input(393) or input(392) or 
                input(391) or input(390) or input(389) or input(388) or input(387) or input(386) or input(385) or input(384);

slice_or(5)  <= input(383) or input(382) or input(381) or input(380) or input(379) or input(378) or input(377) or input(376) or 
                input(375) or input(374) or input(373) or input(372) or input(371) or input(370) or input(369) or input(368) or 
                input(367) or input(366) or input(365) or input(364) or input(363) or input(362) or input(361) or input(360) or 
                input(359) or input(358) or input(357) or input(356) or input(355) or input(354) or input(353) or input(352) or 
                input(351) or input(350) or input(349) or input(348) or input(347) or input(346) or input(345) or input(344) or 
                input(343) or input(342) or input(341) or input(340) or input(339) or input(338) or input(337) or input(336) or 
                input(335) or input(334) or input(333) or input(332) or input(331) or input(330) or input(329) or input(328) or 
                input(327) or input(326) or input(325) or input(324) or input(323) or input(322) or input(321) or input(320);

slice_or(4)  <= input(319) or input(318) or input(317) or input(316) or input(315) or input(314) or input(313) or input(312) or 
                input(311) or input(310) or input(309) or input(308) or input(307) or input(306) or input(305) or input(304) or 
                input(303) or input(302) or input(301) or input(300) or input(299) or input(298) or input(297) or input(296) or 
                input(295) or input(294) or input(293) or input(292) or input(291) or input(290) or input(289) or input(288) or 
                input(287) or input(286) or input(285) or input(284) or input(283) or input(282) or input(281) or input(280) or 
                input(279) or input(278) or input(277) or input(276) or input(275) or input(274) or input(273) or input(272) or 
                input(271) or input(270) or input(269) or input(268) or input(267) or input(266) or input(265) or input(264) or 
                input(263) or input(262) or input(261) or input(260) or input(259) or input(258) or input(257) or input(256);

slice_or(3)  <= input(255) or input(254) or input(253) or input(252) or input(251) or input(250) or input(249) or input(248) or 
                input(247) or input(246) or input(245) or input(244) or input(243) or input(242) or input(241) or input(240) or 
                input(239) or input(238) or input(237) or input(236) or input(235) or input(234) or input(233) or input(232) or 
                input(231) or input(230) or input(229) or input(228) or input(227) or input(226) or input(225) or input(224) or 
                input(223) or input(222) or input(221) or input(220) or input(219) or input(218) or input(217) or input(216) or 
                input(215) or input(214) or input(213) or input(212) or input(211) or input(210) or input(209) or input(208) or 
                input(207) or input(206) or input(205) or input(204) or input(203) or input(202) or input(201) or input(200) or 
                input(199) or input(198) or input(197) or input(196) or input(195) or input(194) or input(193) or input(192);

slice_or(2)  <= input(191) or input(190) or input(189) or input(188) or input(187) or input(186) or input(185) or input(184) or 
                input(183) or input(182) or input(181) or input(180) or input(179) or input(178) or input(177) or input(176) or 
                input(175) or input(174) or input(173) or input(172) or input(171) or input(170) or input(169) or input(168) or 
                input(167) or input(166) or input(165) or input(164) or input(163) or input(162) or input(161) or input(160) or 
                input(159) or input(158) or input(157) or input(156) or input(155) or input(154) or input(153) or input(152) or 
                input(151) or input(150) or input(149) or input(148) or input(147) or input(146) or input(145) or input(144) or 
                input(143) or input(142) or input(141) or input(140) or input(139) or input(138) or input(137) or input(136) or 
                input(135) or input(134) or input(133) or input(132) or input(131) or input(130) or input(129) or input(128);

slice_or(1)  <= input(127) or input(126) or input(125) or input(124) or input(123) or input(122) or input(121) or input(120) or 
                input(119) or input(118) or input(117) or input(116) or input(115) or input(114) or input(113) or input(112) or 
                input(111) or input(110) or input(109) or input(108) or input(107) or input(106) or input(105) or input(104) or 
                input(103) or input(102) or input(101) or input(100) or input(99) or input(98) or input(97) or input(96) or 
                input(95) or input(94) or input(93) or input(92) or input(91) or input(90) or input(89) or input(88) or 
                input(87) or input(86) or input(85) or input(84) or input(83) or input(82) or input(81) or input(80) or 
                input(79) or input(78) or input(77) or input(76) or input(75) or input(74) or input(73) or input(72) or 
                input(71) or input(70) or input(69) or input(68) or input(67) or input(66) or input(65) or input(64);

slice_or(0) <= '1'; -- shouldn't matter if it's 0 or 1, it isn't looked at anyway

coarse_encoder: priority_encoder_64 port map(slice_or, c_output);

f_input <= 
  input(4095 downto 4032) when c_output = "111111" else
  input(4031 downto 3968) when c_output = "111110" else
  input(3967 downto 3904) when c_output = "111101" else
  input(3903 downto 3840) when c_output = "111100" else
  input(3839 downto 3776) when c_output = "111011" else
  input(3775 downto 3712) when c_output = "111010" else
  input(3711 downto 3648) when c_output = "111001" else
  input(3647 downto 3584) when c_output = "111000" else
  input(3583 downto 3520) when c_output = "110111" else
  input(3519 downto 3456) when c_output = "110110" else
  input(3455 downto 3392) when c_output = "110101" else
  input(3391 downto 3328) when c_output = "110100" else
  input(3327 downto 3264) when c_output = "110011" else
  input(3263 downto 3200) when c_output = "110010" else
  input(3199 downto 3136) when c_output = "110001" else
  input(3135 downto 3072) when c_output = "110000" else
  input(3071 downto 3008) when c_output = "101111" else
  input(3007 downto 2944) when c_output = "101110" else
  input(2943 downto 2880) when c_output = "101101" else
  input(2879 downto 2816) when c_output = "101100" else
  input(2815 downto 2752) when c_output = "101011" else
  input(2751 downto 2688) when c_output = "101010" else
  input(2687 downto 2624) when c_output = "101001" else
  input(2623 downto 2560) when c_output = "101000" else
  input(2559 downto 2496) when c_output = "100111" else
  input(2495 downto 2432) when c_output = "100110" else
  input(2431 downto 2368) when c_output = "100101" else
  input(2367 downto 2304) when c_output = "100100" else
  input(2303 downto 2240) when c_output = "100011" else
  input(2239 downto 2176) when c_output = "100010" else
  input(2175 downto 2112) when c_output = "100001" else
  input(2111 downto 2048) when c_output = "100000" else
  input(2047 downto 1984) when c_output = "11111"  else
  input(1983 downto 1920) when c_output = "11110"  else
  input(1919 downto 1856) when c_output = "11101"  else
  input(1855 downto 1792) when c_output = "11100"  else
  input(1791 downto 1728) when c_output = "11011"  else
  input(1727 downto 1664) when c_output = "11010"  else
  input(1663 downto 1600) when c_output = "11001"  else
  input(1599 downto 1536) when c_output = "11000"  else
  input(1535 downto 1472) when c_output = "10111"  else
  input(1471 downto 1408) when c_output = "10110"  else
  input(1407 downto 1344) when c_output = "10101"  else
  input(1343 downto 1280) when c_output = "10100"  else
  input(1279 downto 1216) when c_output = "10011"  else
  input(1215 downto 1152) when c_output = "10010"  else
  input(1151 downto 1088) when c_output = "10001"  else
  input(1087 downto 1024) when c_output = "10000"  else
  input(1023 downto 960)  when c_output = "1111"   else
  input(959 downto 896)   when c_output = "1110"   else
  input(895 downto 832)   when c_output = "1101"   else
  input(831 downto 768)   when c_output = "1100"   else
  input(767 downto 704)   when c_output = "1011"   else
  input(703 downto 640)   when c_output = "1010"   else
  input(639 downto 576)   when c_output = "1001"   else
  input(575 downto 512)   when c_output = "1000"   else
  input(511 downto 448)   when c_output = "111"    else
  input(447 downto 384)   when c_output = "110"    else
  input(383 downto 320)   when c_output = "101"    else
  input(319 downto 256)   when c_output = "100"    else
  input(255 downto 192)   when c_output = "11"     else
  input(191 downto 128)   when c_output = "10"     else
  input(127 downto 64)    when c_output = "1"      else
  input(63 downto 0);

fine_encoder: priority_encoder_64 port map(f_input, output(g_log2q - 1 downto 0));

output(g_log2n - 1 downto g_log2q) <= c_output(g_log2k - 1 downto 0);
end;